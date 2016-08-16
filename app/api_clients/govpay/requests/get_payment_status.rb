module Govpay
  module Requests
    class GetPaymentStatus
      include Govpay::Api

      def initialize(fee)
        @fee = fee
      end

      def call
        get
        if ok?
          Responses::PaymentStatus.new(response_body)
        else
          Responses::ApiError.new(StandardError.new(response_body))
        end
      end

      private

      def endpoint
        "/payments/#{@fee.govpay_payment_id}"
      end
    end
  end
end
