module Govpay
  module Responses
    class PaymentStatus
      def initialize(govpay_response)
        @govpay_response = govpay_response
      end

      def status
        @govpay_response[:state][:status]
      end

      def message
        @govpay_response[:state][:message]
      end
    end
  end
end
