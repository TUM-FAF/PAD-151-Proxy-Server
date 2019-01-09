require_relative 'http_request'
require_relative 'http_response'
require_relative 'handler'
require 'json'

class RequestHandler
  include Handler

  def initialize(event_machine, database)
    @em = event_machine
    @db = database
  end
  
  def handle(request)
    puts "REQUEST"
    p request

    if request.http_method == 'POST'
      puts 'Try create a joke'
      @db.create(request.body)
    end

    response_status = 200
    response_header = {
      'Content-Type' => 'application/json'
    }
    response_content = @db.all.to_json
    response = HttpResponse.new(response_status, response_header, response_content)

    puts 'Response info:'
    p response
    send_response(@em, response)
  end
  
end