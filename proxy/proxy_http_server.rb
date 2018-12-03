require 'eventmachine'
require 'em-http-request'
require 'evma_httpserver'
require_relative 'http_cache'
require_relative 'converter'

class ProxyHttpServer < EM::Connection
  include EM::HttpServer
  include HttpCache
  include Converter

  def post_init
    super
    init_cache
    no_environment_strings
  end

  def process_http_request
    #   @http_protocol
    #   @http_request_method
    #   @http_cookie
    #   @http_if_none_match
    #   @http_content_type
    #   @http_path_info
    #   @http_request_uri
    #   @http_query_string
    #   @http_post_content
    #   @http_headers

    @headers = @http_headers.split("\x00").map{ |e| e.split(': ', 2) }.to_h
    puts "info"
    p @headers
    puts @http_request_method
    puts @http_request_uri

    cache_key = [@http_request_method, @http_request_uri].join(' ')

    if @http_request_method == 'GET'
      cache = try_restore_from_cache(cache_key)
      puts "I have '#{cache_key}': #{cache}"
    end

    if cache != nil
      send_cached_response({'CONTENT_TYPE' => 'application/xml'}, cache)
    else
      forward_request
    end
  end

  def send_cached_response(headers, cache)
    send_response(headers, cache)
  end

  def forward_request
    forward_header = @headers
    forward_header['Accept'] = 'text/json'
    http = EventMachine::HttpRequest.new('http://warehouse:9191')

    if @http_request_method == 'GET'
      http.get :head => forward_header
    elsif @http_request_method == 'POST'
      http.post :head => forward_header, body: => convert_to_json(convert_from_xml(@http_post_content))
    end

    http.errback { p "Uh oh #{http.error}" }

    http.callback do
      response_header = http.response_header
      response_header['CONTENT_TYPE'] = 'application/xml'

      dummy_content = '{foo: bar}'
      content = '<?xml version="1.0" encoding="UTF-8"?>' + convert_to_xml(convert_from_json(dummy_content))
      p http.response_header.status
      p http.response_header
      p http.response
      p content

      cache_key = [@http_request_method, @http_request_uri].join(' ')
      store_in_cache(cache_key, content)
      send_response(response_header, content)
    end
  end

  def send_response(headers, body, status = 200)
    response = EM::DelegatedHttpResponse.new(self)
    response.status = status
    response.content_type headers['CONTENT_TYPE']
    response.content = body
    response.send_response
  end
end
