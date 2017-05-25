class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses, :dependent => :destroy, inverse_of: :post
	has_many :comments
  has_many :custom_points
  #after_create :set_first_points
  after_save :get_midpoints
  

	accepts_nested_attributes_for :addresses, 
	:allow_destroy => true, :reject_if => :all_blank
  $test="nil"

  def addresses_check?
    changed = false
    self.addresses.each do |address|
      changed = true if address.street_changed? || address.city_changed? || 
      address.state_changed? || address.zip_changed? || self.addresses_count_changed?
      break if changed
    end
    changed
  end

  def create_point(lat, lon, dis_left, dis_sor)
    CustomPoint.create(latitude: lat, longitude: lon, distance_left: dis_left, distance_source: dis_sor, post_id: self.id)
  end

  private def set_first_points
    self.addresses.each_with_index do |address, index|
      address.has_point = true
      lat = address.latitude
      lon = address.longitude
      distance_source = address.distance_to(self.addresses.first)
      distance_left = address.distance_to(self.addresses[index-1]) unless index==0 || index == 1 || index == 2
      distance_left = distance_source if index==2 || (index==1 && self.addresses.count==2)
      distance_left = address.distance_to(self.addresses.last) if index==1 && self.addresses.count > 2
      distance_left = 0 if index==0

      create_point(lat, lon, distance_left, distance_source)
    end
  end

  private def set_points
    $test = "changed"
    CustomPoint.where(:post_id=>self.id).destroy_all
    set_first_points
  end

  def get_distance
    $test
  end

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

    if !detours.nil?
      detours.each_with_index do |detour, index|
        unless index+1==detours.count
          detour_group = detour_group + detour + "|"
        else
          detour_group = detour_group + detour
        end
      end
    detour_tag = detour_tag + detour_group
    end

    origin_tag = origin_tag + origin_coord
    destination_tag = destination_tag + destination_coord
    detour_tag.nil? ? main_string = main_string + origin_tag + destination_tag : main_string = main_string + origin_tag + destination_tag + detour_tag
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
  $outArr = Array.new()
  $outArr2 = Array.new()
  $t = true

  private def get_midpoints
    lat1 = self.addresses[0].latitude
    lon1 = self.addresses[0].longitude

    lat2 = self.addresses[1].latitude    
    lon2 = self.addresses[1].longitude

    @limit = 5
  
    @dis = self.addresses.first.distance_to(self.addresses.second)

    latLon = CustomPoint.new()

    t = 0
    
    #source
    point1 = create_point(lat1, lon1, 0, 0)

    $outArr.push(point1)

    #destination
    point2 = create_point(lat2, lon2, 0, @dis)

    $outArr.push(point2)
    $outArr2 = $outArr
   
    t1 = $outArr.count

    if @dis >= @limit
      while ($t)
        i = 0 
        while  (i < t1 - 1)
          cal_midpoint($outArr[i].latitude, $outArr[i].longitude,
             $outArr[i+1].latitude, $outArr[i+1].longitude,
              self.addresses.first, i)
          #$outArr.sort_by {|obj| obj.distance_source}          
          i += 1
        end
        $outArr = $outArr2
        t1 = $outArr.count
      end  
    end

    i = $outArr.count - 1
    dis = Geocoder::Calculations.distance_between([$outArr[i].latitude, $outArr[i].longitude], [$outArr[i - 1].latitude, $outArr[i - 1].longitude])
    $outArr[i].distance_left = dis
    
    $outArr.each do |cp|
      cp.save
    end

    $outArr.clear
    $outArr2.clear
    $t = true

  end

  
  #This method calculates and stores the midpoints in the table
  def cal_midpoint(lat1, lon1, lat2, lon2, sou, index)
    midpoint = Geocoder::Calculations.geographic_center([[lat1, lon1], [lat2, lon2]])
    lat3 = midpoint[0]
    lon3 = midpoint[1]

    #first save the current midpoint
    mid_temp = CustomPoint.new
    mid_temp.latitude = lat3
    mid_temp.longitude = lon3
    mid_temp.distance_source = sou.distance_to([lat3, lon3])
    mid_temp.distance_left = Geocoder::Calculations.distance_between([lat3, lon3], [$outArr[index].latitude, $outArr[index].longitude])
    mid_temp.post_id = self.id
    $outArr2.push(mid_temp) 
    $outArr2.sort_by! {|obj| obj.distance_source}
    dis = Geocoder::Calculations.distance_between([$outArr2[0].latitude, $outArr2[0].longitude] , [$outArr2[1].latitude, $outArr2[1].longitude])
      
    #create_point(lat3, lon3, 0, distan)  
    if dis <= 5
      $t = false
    end
  end

  def get_midpoints2

    self.addresses.each_with_index do |address, index|
      address.has_point = true
      lat = address.latitude
      lon = address.longitude
      distance_source = address.distance_to(self.addresses.first)
      distance_left = address.distance_to(self.addresses[index-1]) unless index==0 || index == 1 || index == 2
      distance_left = distance_source if index==2 || (index==1 && self.addresses.count==2)
      distance_left = address.distance_to(self.addresses.last) if index==1 && self.addresses.count > 2
      distance_left = 0 if index==0

      create_point(lat, lon, distance_left, distance_source)
    end

    created_midpoints = CustomPoint.where(:post_id=>self.id).order("distance_source")
    tobeworked = Array.new

    created_midpoints.each_with_index do |point, index|
      next if index==0
      done = false

      subject = point
      left_point = created_midpoints[index-1]

      while !done
        if(subject.distance_left >= 5)
          co1 = [subject.latitude, subject.longitude]
          co2 = [left_point.latitude, left_point.longitude]
          midpoints = Geocoder::Calculations.geographic_center(co1, co2)
          left = Geocoder::Calculations.distance_between(co1[0], co1[1], co2[0], co2[1])
          source = self.addresses.first.distance_to(co2[0], co2[1])
          subject = create_point(midpoints[0], midpoints[1], left, source)
          tobeworked.push(subject)
        elsif tobeworked.any?
          tobeworked.each_with_index do |new, i|
            if index==0
              tobeworked.pop
              next
            end
            left_point = subject
            subject = tobeworked.pop
          end
        end
      end
    end
    
  end


  private_class_method :search_through_addresses, :check_address, :check_street ,:check_city, :check_zip

end
