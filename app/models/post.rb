class Post < ApplicationRecord
	belongs_to :user
	has_many :addresses, :dependent => :destroy, inverse_of: :post

	accepts_nested_attributes_for :addresses, 
	:allow_destroy => true, :reject_if => :all_blank
end
