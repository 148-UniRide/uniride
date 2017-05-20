class CreateMidpoints < ActiveRecord::Migration[5.0]
  def change
    create_table :midpoints do |t|
      t.float :longitude
      t.float :latitude
      t.integer :left
      t.integer :right

      t.timestamps
    end
  end
end
