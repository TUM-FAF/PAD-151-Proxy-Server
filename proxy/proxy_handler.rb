require_relative 'http_request'
require_relative 'request_handler'
require_relative 'xml_validator'
require_relative 'converter'
require 'em-http-request'

class ProxyHandler
  include RequestHandler
  include Converter
  include XMLValidator

  def initialize(em)
    @em = em
  end

  def handle_request(http_request)
    puts "Handled by proxy handler."
    handle(http_request)
  end

  private
    def handle(http_request)
      http_request.header['Accept'] = 'text/json'

      if http_request.http_method == 'GET'
        http = EventMachine::HttpRequest.new('http://warehouse:9191').get(:head => http_request.header)
      elsif @http_request.http_method == 'POST'
        is_valid, errors = XMLValidator.validate(http_request.body, File.read("XSD/post_joke.xsd"))
        if !is_valid
          send_response(@em, {'CONTENT_TYPE' => 'application/xml'}, nil, 404)
          return
        end
        body = convert_to_json(convert_from_xml(http_request.body))
        http = EventMachine::HttpRequest.new('http://warehouse:9191')
              .post(:head => http_request.header, :body => body)
      end

      http.errback do
        puts "ERROR: #{http.error}"
      end

      http.callback do
        response_header = http.response_header
        response_header['CONTENT_TYPE'] = 'application/xml'
        content = '<?xml version="1.0" encoding="UTF-8"?>' + convert_to_xml(convert_from_json(http.response))
        p http.response_header.status
        p http.response_header
        p http.response
        p content

        # cache_key = [@http_request_method, @http_request_uri].join(' ')
        # store_in_cache(cache_key, content)
        send_response(@em, response_header, content)
      end
    end
end
