require_relative 'http_response'
require_relative 'converter'
require_relative 'request_handler'
require_relative 'cache_policy'
require 'em-http-request'

class ProxyGetHandler
  include Converter
  include RequestHandler

  def initialize(em)
    @em = em
    @policy = CachePolicy.new
  end
  
  def execute(request)
    EventMachine::HttpRequest.new('http://warehouse:9191').get(:head => request.header)
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

    update_cache_if_needed(request, response)
    send_response(@em, response)    
  end


  def update_cache_if_needed(request, response)
    cache_key = request.uri
    if @policy.should_update_cache?(cache_key, request)
      expiry = @policy.get_expiration_time(request)
      HttpCache.store_in_cache(cache_key, YAML::dump(response), expiry)
    end
  end
end
