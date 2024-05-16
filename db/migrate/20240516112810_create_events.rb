class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :address_id
      t.date :event_date
      t.integer :participant_count

      t.timestamps
    end
  end
end
