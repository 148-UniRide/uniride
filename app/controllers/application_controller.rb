class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :first_letter_uppercase
  
  #mailbox helpers
  helper_method :mailbox, :conversation


  	#next two lines can be removed. fallback for carrierwave error: "unintialized constant"
  	require 'carrierwave'
	require 'carrierwave/orm/activerecord'

	def first_letter_uppercase(str)
		capitalized = str.slice(0,1).capitalize + str.slice(1..-1)
	end

  private

  def mailbox
  	@mailbox ||= current_user.mailbox
  end

  def conversation
    @conversation ||= mailbox.conversations.find(params[:id])
  end


end
