class Address < ApplicationRecord
	belongs_to :post, required: false
end
