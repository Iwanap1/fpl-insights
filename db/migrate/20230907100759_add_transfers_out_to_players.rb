class AddTransfersOutToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :transfers_out, :integer
  end
end
