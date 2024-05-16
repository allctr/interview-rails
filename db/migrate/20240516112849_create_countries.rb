class CreateCountries < ActiveRecord::Migration[6.1]
  def change
    create_table :countries do |t|
      t.string :name
      t.json :polygon_info

      t.timestamps
    end
  end
end
