module Embedly
  module Request
    class Base
      attr_accessor :api

      def initialize(api)
        @api = api
      end

      def get(uri, options = {})
        raise NotImplementedError
      end
    end
  end
end
