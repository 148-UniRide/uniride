class MidpointsController < ApplicationController

	def index
	end

	def show
	end

	def new
	end

	def create_this
		midpoint = Midpoint.new(midpoints_params)
		
		midpoint.save
	end

	private 
		def midpoints_params
      		params.require(:midpoint).permit(:latitude, :longitude, :left, :right, :dist_from_current_source, :post_id)
    	end
end
