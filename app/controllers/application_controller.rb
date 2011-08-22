class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :load_players
  
  protected
  def load_players
    @players = Player.all
  end
end
