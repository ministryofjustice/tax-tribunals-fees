module Govpay
  module Responses
    class PaymentCreated
      def initialize(govpay_response)
        @govpay_response = govpay_response
      end

      def govpay_id
        @govpay_response.fetch(:payment_id)
      end

      def payment_url
        @govpay_response.fetch(:_links).fetch(:next_url).fetch(:href)
      end
    end
  end
end
