class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.references :away_team, null: false, foreign_key: true
      t.references :home_team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
