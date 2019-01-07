require 'eventmachine'
require_relative 'proxy_http_server'

EM.run{
  EM.start_server '0.0.0.0', ENV['PROXY_PORT'], ProxyHttpServer
}
