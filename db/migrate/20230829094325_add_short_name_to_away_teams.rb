class AddShortNameToAwayTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :away_teams, :short_name, :string
  end
end
