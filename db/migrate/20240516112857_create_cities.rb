class CreateCities < ActiveRecord::Migration[6.1]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :country_id
      t.json :polygon_info

      t.timestamps
    end
  end
end
