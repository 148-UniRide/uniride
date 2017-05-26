class ChangeDistanceTypesForCustomPoints < ActiveRecord::Migration[5.0]
	def change
		change_column :custom_points, :distance_left, :float
		change_column :custom_points, :distance_source, :float
	end
end
