module Govpay
  module Responses
    class PaymentStatus
      def initialize(govpay_response)
        @govpay_response = govpay_response
      end

      def status
        state.fetch(:status)
      end

      def message
        # Messages only occur in the event of an api error. See the api
        # document for details: https://gds-payments.gelato.io
        state.fetch(:message) if state.key?(:message)
      end

      private

      def state
        @state ||= @govpay_response.fetch(:state)
      end
    end
  end
end
