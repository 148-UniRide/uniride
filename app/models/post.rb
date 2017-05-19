class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses, :dependent => :destroy, inverse_of: :post
	has_many :comments

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
    results = Array.new
    Post.all.each do |post|
      results.push(post) if (check_address(post.addresses.first, street1, city1, zip1) || check_address(post.addresses.second, street2, city2, zip2))
    end
    results
  end

  private

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

end
