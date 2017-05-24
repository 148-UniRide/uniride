class CreateCustomPoints < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_points do |t|
      t.float :latitude
      t.float :longitude
      t.integer :distance_left
      t.integer :distance_source
      t.references :post, foreign_key: true

      t.timestamps
    end
  end
end
