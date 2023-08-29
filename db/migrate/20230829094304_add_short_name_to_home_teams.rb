class AddShortNameToHomeTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :home_teams, :short_name, :string
  end
end
