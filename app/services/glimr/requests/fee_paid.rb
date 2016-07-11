module Glimr
  module Requests
    class FeePaid < Base
      def initialize(fee_liability)
        @fee_liability = fee_liability
      end

      def call
        if response.success?
          Responses::FeePayment.new(response)
        else
          Responses::CaseNotFound.new(response)
        end
      end

      private

      def response
        @response ||= api.post(endpoint, body)
      end

      def endpoint
        '/paymenttaken'
      end

      def body
        {
          feeLiabilityId: @fee_liability.glimr_id,
          paymentReference: @fee_liability.govpay_reference,
          govpayReference: @fee_liability.govpay_payment_id,
          paidAmountInPence: @fee_liability.amount
        }
      end
    end
  end
end
