require 'eventmachine'
require 'em-http-request'
require 'evma_httpserver'
require_relative 'http_cache'

class ProxyHttpServer < EM::Connection
  include EM::HttpServer
  include HttpCache

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
    cache = try_restore_from_cache(cache_key)
    puts "I have '#{cache_key}': #{cache}"

    if cache != nil
      send_cached_response(nil, cache, 'text/html')
    else
      forward_request
    end
  end

  def send_cached_response(headers, cache, content_type)
    send_response(headers, cache, content_type)
  end

  def forward_request
    http = EventMachine::HttpRequest.new('http://warehouse:9191').get
    http.errback { p "Uh oh #{http.error}" }

    http.callback do
      p http.response_header.status
      p http.response_header
      p http.response
      content = http.response
      cache_key = [@http_request_method, @http_request_uri].join(' ')
      store_in_cache(cache_key, content)
      send_response(http.response_header, content)
    end
  end

  def send_response(headers, body, content_type = 'text/html', status = 200)
    response = EM::DelegatedHttpResponse.new(self)
    response.status = status
    response.content_type content_type
    response.content = body
    response.send_response
  end
end
