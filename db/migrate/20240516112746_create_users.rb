class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :address_id
      t.json :healthcare_info

      t.timestamps
    end
  end
end
