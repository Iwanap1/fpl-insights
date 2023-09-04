class AddColumnsToFixtures < ActiveRecord::Migration[7.0]
  def change
    add_column :fixtures, :away_goals, :string
    add_column :fixtures, :home_goals, :string
    add_column :fixtures, :away_assists, :string
    add_column :fixtures, :home_assists, :string
    add_column :fixtures, :away_own_goals, :string
    add_column :fixtures, :home_own_goals, :string
    add_column :fixtures, :away_penalties_saved, :string
    add_column :fixtures, :home_penalties_saved, :string
    add_column :fixtures, :away_penalties_missed, :string
    add_column :fixtures, :home_penalties_missed, :string
    add_column :fixtures, :away_yellow_cards, :string
    add_column :fixtures, :home_yellow_cards, :string
    add_column :fixtures, :away_red_cards, :string
    add_column :fixtures, :home_red_cards, :string
    add_column :fixtures, :away_saves, :string
    add_column :fixtures, :home_saves, :string
    add_column :fixtures, :away_bonus, :string
    add_column :fixtures, :home_bonus, :string
  end
end
