module Glimr
  module Requests
    class FeePaid
      include Glimr::Api

      def initialize(fee_liability)
        @fee_liability = fee_liability
      end

      def call
        if ok?
          Responses::FeePayment.new(response_body)
        else
          Responses::CaseNotFound.new(response_body)
        end
      end

      private

      def endpoint
        '/paymenttaken'
      end

      def request_body
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
