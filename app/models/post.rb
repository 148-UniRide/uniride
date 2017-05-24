class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses, :dependent => :destroy, inverse_of: :post
	has_many :comments
  after_save :get_midpoints
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
  private def get_midpoints     
    lat1 = self.addresses[0].latitude
    lon1 = self.addresses[0].longitude

    lat2 = self.addresses[1].latitude    
    lon2 = self.addresses[1].longitude

    @limit = 5
  
    dist = Geocoder::Calculations.distance_between([lat1, lon1], [lat2, lon2])
   
    if dist >= @limit
      cal_midpoint(lat1, lon1, lat2, lon2, 0, 1, lat1, lon1)
    end
  end

  
  #This method calculates and stores the midpoints in the table
  def cal_midpoint(lat1, lon1, lat2, lon2, source_id, des_id, s_lat1, s_lon1)
    t1 = lon2 - lon1
    dLon = t1 * Math::PI / 180

    #convert to radians
    l1 = lat1 * Math::PI / 180
    l2 = lat2 * Math::PI / 180
    lo1 = lon1 * Math::PI / 180

    bx = Math.cos(l2) * Math.cos(dLon)
    by = Math.cos(l2) * Math.sin(dLon)
    lat3 = Math.atan2(Math.sin(l1) + Math.sin(l2), Math.sqrt((Math.cos(l1) + bx) * (Math.cos(l1) + bx) + by * by))
    lon3 = lo1 + Math.atan2(by, Math.cos(l1) + bx)

    lat3 = lat3 * 180 / Math::PI
    lon3 = lon3 * 180 / Math::PI

    #math.atan(x) = returns arc tangent of x
    #math.atan2(x, y) = Returns atan(y/x ) in radians. 
    #Calculation for the midpoint *end*

    #first save the current midpoint
    mid_temp = Midpoint.new
    mid_temp.latitude = lat3
    mid_temp.longitude = lon3
    mid_temp.left = source_id
    mid_temp.right = des_id
    mid_temp.dist_from_current_source = Geocoder::Calculations.distance_between([s_lat1, s_lon1], [lat3, lon3])
    mid_temp.post_id = self.id
    mid_temp.save
    
    #From mid to left
    dist = Geocoder::Calculations.distance_between([lat1, lon1], [lat3, lon3])
    #from mid to right
    dist_r = Geocoder::Calculations.distance_between([lat3, lon3], [lat2, lon2])
    #First check left side
    if(dist >= @limit)
      #print "Distance between lat1: #{lat1}, lon1: #{lon1} and lat3: #{lat3} and lon3: #{lon3}: "
      #print dist
      cal_midpoint(lat1, lon1, lat3, lon3, source_id, des_id, s_lat1, s_lon1)
    end
    if(dist_r >= @limit)
      cal_midpoint(lat3, lon3, lat2, lon2, source_id, des_id, s_lat1, s_lon1)
    end
  end
end
