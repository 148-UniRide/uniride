class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses, :dependent => :destroy, inverse_of: :post
	has_many :comments
  before_save :get_midpoints
  has_many :midpoints
	accepts_nested_attributes_for :addresses, 
	:allow_destroy => true, :reject_if => :all_blank


  def set_iframe_src
    main_string = "https://www.google.com/maps/embed/v1/directions?key=AIzaSyD1zV2b2rTtvUYLSOL9CiNxTKiB2hMBeCI"
    origin_tag = "&origin="
    destination_tag = "&destination="
    origin_coord = ""
    destination_coord = ""
    if self.addresses.count>2
      detours = Array.new
      detour_group = ""
      detour_tag = "&waypoints="
      detour_coord = ""
    end

    self.addresses.each_with_index do |address, index|
      coordinates = address.latitude.to_s + "," + address.longitude.to_s

      if index==0
        origin_coord = address.street.to_s + "+" + address.city.to_s + "+" + address.state.to_s
      end

      if index==1
        destination_coord = address.street.to_s + "+" + address.city.to_s + "+" + address.state.to_s
      end

      if index>1
        detour_coord = address.street.to_s + "+" + address.city.to_s + "+" + address.state.to_s
        detours << detour_coord
      end

    end

    if self.addresses.count>2
      detours.each_with_index do |detour, index|
        unless index+1==detours.count
          detour_group = detour_group + detour + "|"
        else
          detour_group = detour_group + detour
        end
      end
    end

    if self.addresses.count > 2
      detour_tag = detour_tag + detour_group
    end

    origin_tag = origin_tag + origin_coord   
    destination_tag = destination_tag + destination_coord
    
    if self.addresses.count > 2
      main_string = main_string + origin_tag + destination_tag + detour_tag
    else  
      main_string = main_string + origin_tag + destination_tag
    end

  end

  def self.search(street1, city1, zip1, street2, city2, zip2)
    street1.to_s.rstrip
    city1.to_s.rstrip
    zip1.to_s.rstrip
    street2.to_s.rstrip
    city2.to_s.rstrip
    zip2.to_s.rstrip
    results ||= Array.new
    Post.all.each do |post|
      results.push(post) if search_through_addresses(post, street1, city1, zip1, street2, city2, zip2)
    end
    results
  end

  private

  def self.search_through_addresses(post, street1, city1, zip1, street2, city2, zip2)
    source_matched = false
    source_matched_index = -1
    destination_matched = false
    destination_matched_index = -1

    post.addresses.each_with_index do |address, index|
      next if index==1
      if check_address(address, street1, city1, zip1)
        source_matched = true
        source_matched_index = index
        break
      end
    end

    if source_matched
      source_matched_index==0 ? addresses_destination=post.addresses[2..post.addresses.count-1] : 
      addresses_destination=post.addresses[source_matched_index..post.addresses.count-1]

      addresses_destination.each_with_index do |address, index|
        if check_address(address, street2, city2, zip2)
          destination_matched = true
          destination_matched_index = index
          break
        end
        if index == addresses_destination.count-1
          if check_address(post.addresses.second, street2, city2, zip2)
            destination_matched = true
            destination_matched_index = 1
            break
          end
        end
      end
    end

    source_matched && destination_matched ? true : false
  end

  def self.check_address(address, street, city, zip)
    check_street(address, street) || 
        check_city(address, city) || 
        check_zip(address, zip)
  end


  def self.check_street(address, street)
    street.nil? || street.empty? ? false : address.street.downcase==street.downcase
  end

  def self.check_city(address, city)
    city.nil? || city.empty? ? false : address.city.downcase==city.downcase  
  end

  def self.check_zip(address, zip)
    zip.nil? || zip.empty? ? false : address.zip==zip
  end

  #code for finding midpoints
  #currently only checks for midpoints between source and destination
  def self.get_midpoints
    source = self.addresses.first
    destination = self.addresses.second

    @limit = 5

    dist = source.distance_to(destination)
       
    if dist >= limit
      cal_midpoint(source.latitude, source.longitude, destination.latitude, destination.longitude, left_add, right_add, 0, 1)
    end
  end

  
  #This method calculates and stores the midpoints in the table
  def self.cal_midpoint(lat1, lon1, lat2, lon2, source_id, des_id)
    temp = Address.new #this is just so the distance_to(lat, long) method can be used
    temp.latitude = lat1
    temp.longitude = lon1

    temp2 = Address.new
    temp2.latitude = lat2
    temp2.longitude = lon2
   
    #Calculation for the midpoint *start*
    t1 = lon2 - lon1
    dLon = t1 * Math::PI / 180

    #convert to radians
    lat1 = lat1 * Math::PI / 180
    lat2 = lat2 * Math::PI / 180
    lon1 = lon1 * Math::PI / 180

    bx = Math.cos(lat2) * Math.cos(dLon)
    by = Math.cos(lat2) * Math.sin(dLon)
    lat3 = Math.atan2(Math.sin(lat1) + Math.sin(lat2), Math.sqrt((Math.cos(lat1) + bx) * (Math.cos(lat1) + bx) + by * by))
    lon3 = lon1 + Math.atan2(by, Math.cos(lat1) + bx)

    #math.atan(x) = returns arc tangent of x
    #math.atan2(x, y) = Returns atan(y/x ) in radians. 
    #Calculation for the midpoint *end*

    #first save the current midpoint
    mid_temp = Midpoint.new
    mid_temp.latitude = lat3
    mid_temp.longitude = lon3
    mid_temp.left = source_id
    mid_temp.right = des_id
    mid_temp.dest_from_current_source = self.addresses[source_id].distance_to([lat3, lon3])
    mid_temp.post_id = self.id
    mid_temp.save
    
    #From mid to left
    dist_l = temp.distance_to([lat3, lon3])
    #from mid to right
    dist_r = temp2.distance_to([lat3, lon3])
    #First check left side
    if(dist_l >= @limit)
      cal_midpoint(lat1, lon1, lat3, lon3, source_id, des_id)
    end  
    #Then check the right side
    if(dest_r >= @limit)
      cal_midpoint(lat3, lon3, lat2, lon2, source_id, des_id)
    end
  end
end
