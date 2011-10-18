class Player < ActiveRecord::Base
  has_many :chats
  belongs_to :block
  
  after_create :set_password
  
  protected
  def set_password
    update_attribute :password, SecureRandom.hex[0...8]
  end
end
