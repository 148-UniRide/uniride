class ChangeFlagForAddresses < ActiveRecord::Migration[5.0]
  def change
  	change_column :addresses, :has_point, :boolean, null: false, default: false
  end
end
