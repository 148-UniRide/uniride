class AddDistFromCurrentSourceToMidpoints < ActiveRecord::Migration[5.0]
  def change
    add_column :midpoints, :dist_from_current_source, :float
  end
end
