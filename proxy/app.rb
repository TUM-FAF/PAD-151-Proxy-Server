require 'socket' # Provides TCPServer and TCPSocket classes

puts "Running server on localhost:#{ENV['PROXY_PORT']}"

server = TCPServer.new ENV['PROXY_PORT']

while session = server.accept
  request = session.gets
  puts request

  session.print "HTTP/1.1 200\r\n" # 1
  session.print "Content-Type: text/html\r\n" # 2
  session.print "\r\n" # 3
  session.print "Hello world! The time is #{Time.now}" #4

  session.close
end
