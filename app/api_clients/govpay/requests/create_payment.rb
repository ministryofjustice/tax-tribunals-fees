module Govpay
  module Requests
    class CreatePayment < Base
      def initialize(fee_liability)
        @fee_liability = fee_liability
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
            routes.url_helpers.post_pay_liability_url(@fee_liability),
          description: @fee_liability.govpay_description,
          reference: @fee_liability.govpay_reference,
          amount: @fee_liability.amount
        )
      end
    end
  end
end
