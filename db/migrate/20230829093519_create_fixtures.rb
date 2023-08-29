class CreateFixtures < ActiveRecord::Migration[7.0]
  def change
    create_table :fixtures do |t|
      t.references :home_team, null: false, foreign_key: true
      t.references :away_team, null: false, foreign_key: true
      t.date :date
      t.integer :gameweek_number

      t.timestamps
    end
  end
end
