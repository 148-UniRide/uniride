class AddNames < ActiveRecord::Migration[5.0]
  def change
  	#Adding name fields
  	add_column :users, :firstName, :string
  	add_column :users, :lastName, :string
  end
end
