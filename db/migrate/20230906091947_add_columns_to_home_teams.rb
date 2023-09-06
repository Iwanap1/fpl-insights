class AddColumnsToHomeTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :home_teams, :strength_overall, :integer
    add_column :home_teams, :strength_attack, :integer
    add_column :home_teams, :strength_defence, :integer
  end
end
