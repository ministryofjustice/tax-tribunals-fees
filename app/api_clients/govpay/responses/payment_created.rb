module Govpay
  module Responses
    class PaymentCreated
      def initialize(govpay_response)
        @govpay_response = govpay_response
      end

      def error?
        false
      end

      def govpay_id
        @govpay_response['payment_id']
      end

      def payment_url
        @govpay_response['_links']['next_url']['href']
      end
    end
  end
end
