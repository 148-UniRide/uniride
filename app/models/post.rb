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

end
