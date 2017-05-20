class MidpointsController < ApplicationController

	def index
	end

	def show
	end

	def new
	end

	def create (log, lat, left, right, p_id)
		midpoint = Midpoint.new
		midpoint.longitude = log
		midpoint.latitude = lat
		midpoint.left = left
		midpoint.right = right
		midpoint.post_id = p_id

		midpoint.save
	end
end
