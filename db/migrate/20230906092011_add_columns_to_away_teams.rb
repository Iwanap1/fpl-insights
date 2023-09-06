class AddColumnsToAwayTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :away_teams, :strength_overall, :integer
    add_column :away_teams, :strength_attack, :integer
    add_column :away_teams, :strength_defence, :integer
  end
end
