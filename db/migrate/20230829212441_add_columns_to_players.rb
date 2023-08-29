class AddColumnsToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :selected, :float
    add_column :players, :ict, :integer
    add_column :players, :web_name, :string
    add_column :players, :price, :float
  end
end
