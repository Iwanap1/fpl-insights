class AddImagePathToHomeTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :home_teams, :image_path, :string
  end
end
