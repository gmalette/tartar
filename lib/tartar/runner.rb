class Tartar::Runner
  SLEEP_TIME = 5
  INFOS_TIME = 60
  CHAT_TIME  = 5
  
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
    if (matches = string.match %r{ \[INFO\]\s<(?<player> ([a-zA-Z]+))> (?<string> (.*)) }x)
      player = Player.find_or_create_by_name matches[:player]
      Chat.create(:player => player, :message => matches[:string])
      puts "#{matches[:player]} said: #{matches[:string]}"
    elsif (matches = string.match /Connected players: (.*)/)
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
      @@outstream.puts("list") if (counter % (INFOS_TIME/SLEEP_TIME)) == 0
      
      if (counter % (CHAT_TIME/SLEEP_TIME)) == 0
        Chat.uninserted.each do |chat|
          chat.needs_insertion = false
          chat.save
          @outstream.puts("say <#{chat.player.name}>: #{chat.message}")
        end
      end
      sleep SLEEP_TIME
    end
  end
end