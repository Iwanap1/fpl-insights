class AddColumnsToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :selected, :float
    add_column :players, :ict, :integer
    add_column :players, :web_name, :string
    add_column :players, :price, :float
    add_column :players, :fixture_difficulty, :integer
    add_column :players, :chance, :float
    add_column :players, :transfers_in, :integer
    add_column :players, :penalty_order, :integer
    add_column :players, :expected_goal_involvements, :float
    add_column :players, :expected_goals_conceded, :float
    add_column :players, :minutes, :integer
  end
end
