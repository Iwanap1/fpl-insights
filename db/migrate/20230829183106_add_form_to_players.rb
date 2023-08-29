class AddFormToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :form, :float
  end
end
