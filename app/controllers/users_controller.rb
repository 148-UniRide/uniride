class UsersController < ApplicationController

  def show
  	if user_signed_in?
  		current_id = current_user.id.to_i
  		id = params[:id].to_i
	  	if id==current_id
	  		render action: "profile"
	  	else
	  		@user = User.find(params[:id])
	  	end
	else
		redirect_to log_in_url, :notice=>"You must be logged in to view that page."
	end
  end

  def profile
  	if user_signed_in?
  		@user=current_user
  	else
		redirect_to log_in_url, :notice=>"You must be logged in to view that page."
	end
  end
end
