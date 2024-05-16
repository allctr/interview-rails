class CreateAddresses < ActiveRecord::Migration[6.1]
  def change
    create_table :addresses do |t|
      t.string :line1
      t.string :line2
      t.string :postcode
      t.integer :city_id

      t.timestamps
    end
  end
end
