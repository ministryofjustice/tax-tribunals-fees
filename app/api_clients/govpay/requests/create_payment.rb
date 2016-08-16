module Govpay
  module Requests
    class CreatePayment
      include Govpay::Api

      def initialize(fee)
        @fee = fee
      end

      def call
        post
        if ok?
          Responses::PaymentCreated.new(response_body)
        else
          Responses::CreatePaymentFailed.new(response_body)
        end
      end

      private

      def endpoint
        '/payments'
      end

      def request_body
        {
          return_url: Rails.application.
            routes.url_helpers.post_pay_fee_url(@fee),
          description: @fee.govpay_description,
          reference: @fee.govpay_reference,
          amount: @fee.amount
        }
      end
    end
  end
end
