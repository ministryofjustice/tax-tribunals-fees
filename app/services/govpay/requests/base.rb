module Govpay
  module Requests
    class Base
      attr_writer :api

      # :nocov:
      def self.call(*args)
        new(*args).call
      end
      # :nocov:

      def api
        @api || ::Govpay::Api.new
      end
    end
  end
end
