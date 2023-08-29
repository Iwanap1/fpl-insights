class CreateHomeTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :home_teams do |t|
      t.string :name
      t.integer :difficulty

      t.timestamps
    end
  end
end
