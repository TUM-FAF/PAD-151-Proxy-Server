require_relative 'xml_validator'
require_relative 'converter'
require_relative 'http_response'
require_relative 'request_handler'
require 'em-http-request'

class ProxyPostHandler
  include Converter
  include XMLValidator
  include RequestHandler

  def initialize(em)
    @em = em
  end
  
  def execute(request)
    is_valid, errors = XMLValidator.validate(request.body, File.read("XSD/post_joke.xsd"))
    if !is_valid
      send_response(@em, HttpResponse.new(404, {'Content-Type' => 'application/xml'}, nil))
      return
    end
    body = convert_to_json(convert_from_xml(request.body))
    http = EventMachine::HttpRequest.new('http://warehouse:9191')
          .post(:head => request.header, :body => body)
  end

  def callback(http, request)
    response_status = http.response_header.status
    response_header = Hash[http.response_header.map{|k, v| [k.split('_').map{|k| k.capitalize}.join('-'), v]}]
    response_header['Content-Type'] = 'application/xml'
    xml_prefix = '<?xml version="1.0" encoding="UTF-8"?>'
    response_content = xml_prefix + convert_to_xml(convert_from_json(http.response))
    response = HttpResponse.new(response_status, response_header, response_content)

    puts 'Response info:'
    p response

    HttpCache.remove_from_cache(request.uri)
    send_response(@em, response)
  end

end
