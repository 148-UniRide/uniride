class SearchesController < ApplicationController
	
	def search
		@search = Search.new
		@temp_address = Address.new
	end

	def calc_results street
		@temp_address = Address.new
		@temp_address.city = street
		post = Post.all

		post.each do |p|
			sourc = p.addresses.first
			dest = p.addresses.last
		end  

	end

	def mid_point (lat1, lon1, lat2, lon2)
		t = lon2 - lon1
		dLon = t * Math::PI / 180;

		lat1 = lat1 * Math::PI / 180;
		lat2 = lat2 * Math::PI / 180;
		lon1 = lon1 * Math::PI / 180;

		bx = Math.cos(lat2) * Math.cos(dLon);
		by = Math.cos(lat2) * Math.sin(dLon);
		lat3 = Math.atan2(Math.sin(lat1) + Math.sin(lat2), Math.sqrt((Math.cos(lat1) + bx) * (Math.cos(lat1) + bx) + by * by));
		lon3 = lon1 + Math.atan2(by, Math.cos(lat1) + bx);

	end


	private
    # Never trust parameters from the scary internet, only allow the white list through.
    def address_params
      params.permit(:street, :city, :state, :zip)
    end

end
