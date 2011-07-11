module ApplicationHelper
  def run_server
    puts "Starting server"
    Dir.chdir MINECRAFT_SERVER_FOLDER
    Kernel.exec("java -Xmx1024M -Xms1024M -jar minecraft_server.jar")
  end
  
end
