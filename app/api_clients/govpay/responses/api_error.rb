module Govpay
  module Responses
    class ApiError
      include Glimr::Api

      def initialize(error)
        @error = error
      end

      def status
        @error.try(:status) || 'failed'
      end

      def error?
        true
      end

      def error_code
        @error.class
      end

      def error_message
        @error.try(:message) || 'Govpay error'
      end
      alias message error_message
    end
  end
end
