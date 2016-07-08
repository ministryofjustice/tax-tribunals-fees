module Glimr
  module Requests
    class CaseFees < Base
      def initialize(case_reference:, confirmation_code:)
        @case_reference = case_reference
        @confirmation_code = confirmation_code
      end

      def call
        if response.success?
          Responses::CaseFees.new(response)
        else
          Responses::CaseNotFound.new(response)
        end
      end

      private

      def response
        @response ||= api.post(endpoint, body)
      end

      def endpoint
        '/requestpayablecasefees'
      end

      def body
        {
          jurisdictionId: 8, # TODO: Remove when no longer required in API
          caseNumber: @case_reference,
          caseConfirmationCode: @confirmation_code
        }
      end
    end
  end
end
