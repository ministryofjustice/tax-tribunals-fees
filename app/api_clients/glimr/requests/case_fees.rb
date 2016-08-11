module Glimr
  module Requests
    class CaseFees
      include Glimr::Api

      def initialize(case_reference:, confirmation_code:)
        @case_reference = case_reference
        @confirmation_code = confirmation_code
      end

      def call
        if ok?
          Responses::CaseFees.new(response_body)
        else
          Responses::CaseNotFound.new(response_body)
        end
      end

      private

      def endpoint
        '/requestpayablecasefees'
      end

      def request_body
        {
          jurisdictionId: 8, # TODO: Remove when no longer required in API
          caseNumber: @case_reference,
          caseConfirmationCode: @confirmation_code
        }
      end
    end
  end
end
