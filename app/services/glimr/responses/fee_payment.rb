module Glimr
  module Responses
    class FeePayment
      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      def error?
        false
      end

      def fee_transaction_id
        @glimr_response['feeTransactionId']
      end
    end
  end
end
