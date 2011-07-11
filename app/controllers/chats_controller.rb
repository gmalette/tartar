class ChatsController < ApplicationController
  # GET /chats
  # GET /chats.xml
  def index
    @chat = Chat.new
    @chats = Chat.for_index
    @players = Player.all
  end


  # POST /chats
  # POST /chats.xml
  def create
    @player = Player.find_by_name params[:name]
    if @player && !params[:chat].blank?
      @chat = Chat.create(params[:chat].merge({:player => @player, :needs_insertion => true}))
    end
    @chats = Chat.for_index
  end

end
