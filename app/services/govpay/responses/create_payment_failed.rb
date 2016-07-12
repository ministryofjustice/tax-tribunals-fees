module Govpay
  module Responses
    class CreatePaymentFailed
      def initialize(govpay_response)
        @govpay_response = govpay_response
      end

      def error?
        true
      end

      def error_code
        @govpay_response && @govpay_response['code']
      end

      def error_message
        return unless @govpay_response
        @govpay_response['message'] || @govpay_response['description']
      end
    end
  end
end
