require 'eventmachine'
require_relative 'warehouse_server'

EM.run{
  EM.start_server '0.0.0.0', ENV['WAREHOUSE_PORT'], WarehouseServer
}



# require_relative 'connect_db'

# puts "Running server on localhost:#{ENV['WAREHOUSE_PORT']}"


# server = TCPServer.new ENV['WAREHOUSE_PORT']
# db = ConnectDB.new('faf')

# while (session = server.accept)
#   request = session.gets
#   puts request

#   body = db.all.to_json

#   headers = [
#     'HTTP/1.1 200 OK',
#     "Date: #{Time.now}",
#     'Server: Ruby',
#     'Content-Type: text/html; charset=iso-8859-1',
#     "Content-Length: #{body.length}\r\n\r\n"
#   ].join("\r\n")

#   session.print(headers)
#   session.print(body)

#   session.close
# end
