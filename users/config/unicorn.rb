
worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
listen '/tmp/unicorn-users.sock', :backlog => 64
timeout 90
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  begin
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
  rescue Exception => e
    puts e.message
  end

end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end
