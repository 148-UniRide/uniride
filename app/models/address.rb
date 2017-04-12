class Address < ApplicationRecord
	belongs_to :post, required: false, dependent: :destroy
end
