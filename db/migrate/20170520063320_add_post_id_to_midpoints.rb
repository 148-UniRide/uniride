class AddPostIdToMidpoints < ActiveRecord::Migration[5.0]
  def change
    add_column :midpoints, :post_id, :integer
  end
end
