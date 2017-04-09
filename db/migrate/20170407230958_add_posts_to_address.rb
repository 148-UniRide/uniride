class AddPostsToAddress < ActiveRecord::Migration[5.0]
  def change
  	add_column :addresses, :post_id, :integer
  end
end
