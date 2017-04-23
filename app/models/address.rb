class Address < ApplicationRecord
	belongs_to :post, required: false
  	before_save :format_fields

	geocoded_by :full_address
	after_validation :geocode, if: ->(obj){ obj.full_address.present? and address_changed}
	after_validation :lat_changed?

	def lat_changed?
	    if (self.address_changed)
	        if !(self.latitude_changed?)
	            return false
	        end
	    end
	    return true
	end

	def full_address
		if self.zip == "" || self.zip == " "
			address_string = [street,city,state].to_a.compact.join(", ")
		else
			address_string = [street,city,state,zip].to_a.compact.join(", ")
		end
	end

	private def format_fields
	    street_array = self.street.gsub(/\s+/m, ' ').strip.split(" ")
	    city_array = self.city.gsub(/\s+/m, ' ').strip.split(" ")

	    self.street = self.each_first_letter_uppercase(street_array).join(" ")
	    self.city = self.each_first_letter_uppercase(city_array).join(" ")
	    self.state.strip
	    self.zip.strip
  	end

  	def each_first_letter_uppercase(str_array)
  		capitalized_array = str_array.collect!{ |str|
	       	str = str.slice(0,1).capitalize + str.slice(1..-1)
	    }
  	end

  	def address_changed
  		if self.street_changed? and self.city_changed? and self.state_changed? and self.zip_changed?
  			return true
  		else
  			return false
  		end
  	end

end
