require "net/http"

module Embedly
  module NetHTTP # :nodoc:
    class Request < Embedly::Request::Base
      # Perform request using net/http library
      def get(uri, options = {})
        proxy = options['proxy']
        http_class = if proxy
          logger.debug { 'using Net::HTTP::Proxy' }
          http_class = Net::HTTP::Proxy(proxy[:host], proxy[:port], proxy[:user], proxy[:password])
        else
          Net::HTTP
        end

        http_class.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.read_timeout = options[:timeout]
          http.get([uri.path, uri.query].join('?'), options[:headers])
        end
      end
    end
  end
end

Embedly.configuration.add_requester :net_http do |api|
  Embedly::NetHTTP::Request.new(api)
end
