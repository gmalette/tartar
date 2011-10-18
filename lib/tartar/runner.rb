class Tartar::Runner
  SLEEP_TIME = 5
  INFOS_TIME = 60
  CHAT_TIME  = 5
  
  PlayerNameRegexp = "(?<player>([a-zA-Z0-9]+))"
  ChatRegexp = %r{ \[INFO\]\s<#{PlayerNameRegexp}>\s(?<string>(.*)) }x
  ConnectedRegexp = %r{Connected players: (.*)}
  CommandRegexp =   %r{\[INFO\]\s<#{PlayerNameRegexp}>\s:(?<command>[a-zA-Z].*+)}
  
  @@command_queue = []
  
  def initialize instream, outstream
    @instream = instream
    @outstream = outstream
  end
  
  def run
    Thread.new do
      ask_infos
    end
    watch_infos
  end
  
  def mine string
    if (matches = string.match CommandRegexp)
      execute_commands matches['player'], matches['command']
    elsif (matches = string.match ChatRegexp)
      player = Player.find_or_create_by_name matches[:player]
      Chat.create(:player => player, :message => matches[:string])
      puts "#{matches[:player]} said: #{matches[:string]}"
    elsif (matches = string.match ConnectedRegexp)
      Player.update_all(:online => false)
      puts "Marking all players as offline"
      matches[1].split(",").each do |player|
        p = Player.find_or_create_by_name(player.strip)
        puts "Marking #{player.strip} online"
        p.online = true
        p.save
      end
    else
      puts string
    end
  end
  
  def execute_commands player, command
    p "Found command: #{command}, player: #{player}"
    commands = command.split(/\s/)
    
    player = Player.find_by_name player
    
    case commands[0]
    when "roll"
      max = commands[1] ? commands[1].to_i : 100
      @outstream.puts "say #{player} rolled #{rand(max)} (#{max})"
    when "list"
      names = Player.where(:online => true).collect(&:name).join(", ")
      @outstream.puts "tell #{player.name} Player online: #{names}"
    when "password"
      @outstream.puts "tell #{player.name} your password is : #{player.password}"
    when "wool"
      if player.block
        @outstream.puts "give #{player.name} #{player.block.external_id} #{commands[1] || 1}" 
      else
        @outstream.puts "tell #{player.name} you have no block associated."
      end
    else
      @outstream.puts "tell #{player.name} Unknown Command #{commands[0]}."
    end
  end
  
  def watch_infos
    str = ""
    while s = @instream.read(1)
      str += s
      
      if s.match /\n/
        mine str
        str = ""
      end
    end
  end
  
  def ask_infos
    Signal.trap("TERM") do
      puts "Sending save-all"
      @outstream.puts "save-all"
    end
    counter = 0
    loop do
      counter += 1
      if (counter % (INFOS_TIME/SLEEP_TIME)) == 0
        puts "Listing players"
        @outstream.puts("list")
      end
      
      if (counter % (CHAT_TIME/SLEEP_TIME)) == 0
        Chat.uninserted.each do |chat|
          puts "inserting chat message from #{chat.player.name}"
          chat.needs_insertion = false
          chat.save
          @outstream.puts("say <#{chat.player.name}>: #{chat.message}")
        end
      end
      sleep SLEEP_TIME
    end
  end
end