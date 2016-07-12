module Govpay
  module Responses
    class ApiError
      def initialize(error)
        @error = error
      end

      def error?
        true
      end

      def error_code
        @error.class
      end

      def error_message
        @error.message
      end
    end
  end
end
