# TODO: a better solution is to only load the requester if it is in use,
# rather than loading them all on startup.
begin
  require "typhoeus"

  module Embedly
    module Typhoeus # :nodoc:
      class Request < Embedly::Request::Base
        # Perform request using typhoeus
        def get(uri, options = {})
          options[:timeout] *= 1000
          ::Typhoeus::Request.get uri.to_s, :headers => options[:headers], :timeout => options[:timeout]
        end
      end
    end
  end

  Embedly.configuration.add_requester :typhoeus do |api|
    Embedly::Typhoeus::Request.new(api)
  end
rescue LoadError
end
