begin
  require 'faraday'

  # Patch Faraday::Response to provide a status code
  module Faraday
    class Response
      alias_method :code, :status unless method_defined?(:code)
    end
  end

  module Embedly
    module Request
      class Faraday < Base
        def get(uri, options = {})
          ::Faraday.get(uri.to_s, nil, options[:headers])
        end
      end
    end
  end

  Embedly.configuration.add_requester :faraday do |api|
    Embedly::Request::Faraday.new(api)
  end
rescue LoadError
end
