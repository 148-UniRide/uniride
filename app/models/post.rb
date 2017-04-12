class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses

	accepts_nested_attributes_for :addresses, 
	:allow_destroy => true, :reject_if => :all_blank
end
