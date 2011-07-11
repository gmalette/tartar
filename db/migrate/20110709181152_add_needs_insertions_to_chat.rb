class AddNeedsInsertionsToChat < ActiveRecord::Migration
  def self.up
    add_column :chats, :needs_insertion, :boolean
  end

  def self.down
    remove_column :chats, :needs_insertion
  end
end
