# Launch using unicorn_rails -c config/unicorn.rb -D

# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
worker_processes 1
working_directory "/home/minecraft/sites/minecraft.thirdside.ca"
listen ".socket", :backlog => 64
timeout 30
user 'www-data', 'www-data'
pid "/home/minecraft/sites/minecraft.thirdside.ca/tmp/pids/unicorn.pid"
stderr_path "/home/minecraft/sites/minecraft.thirdside.ca/log/unicorn.stderr.log"
stdout_path "/home/minecraft/sites/minecraft.thirdside.ca/log/unicorn.stdout.log"
preload_app false