class Chat < ActiveRecord::Base
  belongs_to :player
  
  scope :for_index, limit(50).order("created_at desc").includes(:player)
  scope :uninserted, where(:needs_insertion => true).order("created_at asc")
end
