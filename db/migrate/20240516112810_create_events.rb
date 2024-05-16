class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :city_id
      t.integer :country_id

      t.timestamps
    end
  end
end
