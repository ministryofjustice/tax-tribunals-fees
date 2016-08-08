module Govpay
  module Requests
    class CreatePayment < Base
      def initialize(fee)
        @fee = fee
      end

      def call
        if response.success?
          Responses::PaymentCreated.new(response)
        else
          Responses::CreatePaymentFailed.new(response)
        end
      end

      private

      def response
        @response ||= api.post(endpoint, body)
      end

      def endpoint
        '/payments'
      end

      def body
        JSON.dump(
          return_url: Rails.application.
            routes.url_helpers.post_pay_fee_url(@fee),
          description: @fee.govpay_description,
          reference: @fee.govpay_reference,
          amount: @fee.amount
        )
      end
    end
  end
end
