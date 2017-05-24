class AddAddressesCountToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :addresses_count, :integer
  end
end
