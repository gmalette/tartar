namespace :minecraft do
  
  desc "Starts the minecraft server"
  task :start, [:daemon] => :environment do |t, args|
    include ApplicationHelper
    
    pin, ppout = IO.pipe
    ppin, pout = IO.pipe
        
    pid = fork
    
    if pid
      if args[:daemon]
        puts "Daemonizing pid #{Process.pid}, server on pid #{pid}"
        Process.daemon true
      end
      
      ppout.close
      ppin.close
      Process.detach(pid)
      
      Tartar::Runner.new(pin, pout).run

    else
      puts "Reopening STDIN/OUT/ERR"
      STDOUT.reopen(ppout)
      STDIN.reopen(ppin)
      STDERR.reopen(ppout)
      
      run_server
    end
  end
end