class UsersController < ApplicationController
  def show
  	current_id = current_user.id.to_i
  	id = params[:id].to_i
  	if user_signed_in?
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
  	@user=current_user
  end
end
