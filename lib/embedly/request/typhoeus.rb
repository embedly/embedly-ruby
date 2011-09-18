require "typhoeus"

module Embedly
  module Typhoeus
    class Request < Embedly::Request::Base
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
