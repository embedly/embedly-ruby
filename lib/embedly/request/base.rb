module Embedly
  module Request # :nodoc:
    # Interface to create custom requesters
    #
    # == The class
    #
    # If you want to define a custom requester, you should create a class that
    # inherits from this base class.
    #
    # The class should respond to +get+ that receives the uri object and the api
    # options. The method should perform a get request to Embedly api and return
    # a response object:
    #
    #   class MyRequester < Embedly::Request::Base
    #     def get(uri, options = {})
    #       # performs the request
    #     end
    #   end
    #
    # For more examples, see embedly/requests/*.rb files
    #
    # == Adding to configuration
    #
    # Make sure to add your class to +embedly+ requesters, like the following:
    #
    #  Embedly.configuration.add_requester :my_requester do |api|
    #    MyRequester.new(api)
    #  end
    #
    # This way you can configure the API to use your custom request object:
    #
    #    Embedly.configure do |config|
    #      config.request_with :my_requester
    #    end
    #
    class Base
      attr_accessor :api # :nodoc:

      # Receives the current api object
      def initialize(api)
        @api = api
      end

      # Implement this method
      def get(uri, options = {})
        raise NotImplementedError
      end
    end
  end
end
