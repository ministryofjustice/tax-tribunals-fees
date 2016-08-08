module Govpay
  module Requests
    class GetPaymentStatus < Base
      def initialize(fee)
        @fee = fee
      end

      def call
        if response.success?
          Responses::PaymentStatus.new(response)
        else
          Responses::ApiError.new(StandardError.new(response))
        end
      end

      private

      def response
        @response ||= api.get(endpoint)
      end

      def endpoint
        "/payments/#{@fee.govpay_payment_id}"
      end
    end
  end
end
