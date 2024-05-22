class AdjustDifferentStructures < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :name, :string
    remove_column :events, :participant_count, :integer
  end
end
