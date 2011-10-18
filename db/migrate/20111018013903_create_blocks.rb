class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.string :name
      t.string :color
      t.integer :external_id
      t.timestamps
    end
  end
end
