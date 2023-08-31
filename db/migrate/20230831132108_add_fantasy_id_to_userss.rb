class AddFantasyIdToUserss < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :fantasy_id, :integer
  end
end
