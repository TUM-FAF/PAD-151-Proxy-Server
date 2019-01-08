require_relative 'http_request'
require_relative 'request_handler'
require_relative 'xml_validator'
require_relative 'converter'
require_relative 'http_response'
require 'em-http-request'
require 'yaml'

class ProxyHandler
  include RequestHandler
  include Converter
  include XMLValidator

  def initialize(em)
    @em = em
  end

  def handle_request(http_request)
    puts "Handled by #{self.class.to_s}."
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
          send_response(@em, HttpResponse.new(404, {'Content-Type' => 'application/xml'}, nil))
          return
        end
        HttpCache.remove_from_cache(http_request.uri)
        body = convert_to_json(convert_from_xml(http_request.body))
        http = EventMachine::HttpRequest.new('http://warehouse:9191')
              .post(:head => http_request.header, :body => body)
      end

      http.errback do
        puts "ERROR: #{http.error}"
      end

      http.callback do
        response_status = http.response_header.status
        response_header = Hash[http.response_header.map{|k, v| [k.split('_').map{|k| k.capitalize}.join('-'), v]}]
        response_header['Content-Type'] = 'application/xml'
        xml_prefix = '<?xml version="1.0" encoding="UTF-8"?>'
        response_content = xml_prefix + convert_to_xml(convert_from_json(http.response))
        response = HttpResponse.new(response_status, response_header, response_content)

        puts 'Response info:'
        p response

        if http_request.http_method == 'GET'
          cache_key = http_request.uri
          expiration_time = http_request.header['Expires']
          if expiration_time != nil
            expiry = (Time.httpdate(expiration_time) - Time.now).to_i
            HttpCache.store_in_cache(cache_key, YAML::dump(response), expiry)
            puts "Response stored in cache for #{expirity} seconds."
          else
            HttpCache.store_in_cache(cache_key, YAML::dump(response))
            puts 'Response stored in cache.'
          end
        end
        send_response(@em, response)
      end
    end
end
