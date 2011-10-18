class AddBlockToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :block_id, :integer
  end
end
