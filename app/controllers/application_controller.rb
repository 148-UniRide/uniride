class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  	#next two lines can be removed. fallback for carrierwave error: "unintialized constant"
  	require 'carrierwave'
	require 'carrierwave/orm/activerecord'
end
