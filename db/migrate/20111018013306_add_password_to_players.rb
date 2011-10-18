class AddPasswordToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :password, :string
    
    Player.all.each do |p|
      p.update_attribute :password, SecureRandom.hex[0...8]
    end
  end
end
