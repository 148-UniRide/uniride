class AddFlagToAddresses < ActiveRecord::Migration[5.0]
  def change
    add_column :addresses, :has_point, :boolean
  end
end
