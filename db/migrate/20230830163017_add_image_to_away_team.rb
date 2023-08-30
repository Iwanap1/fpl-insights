class AddImageToAwayTeam < ActiveRecord::Migration[7.0]
  def change
    add_column :away_teams, :image_path, :string
  end
end
