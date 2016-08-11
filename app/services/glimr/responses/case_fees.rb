module Glimr
  module Responses
    class CaseFees
      FeeLiability = Struct.new(:glimr_id, :description, :amount)

      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      def error?
        false
      end

      # :nocov:
      # nocov because it’s a pain to get it with feature/request specs as it
      # isn’t really used anywhere and we’re going to deprecate it soon, anyway
      def jurisdiction
        @glimr_response['jurisdictionId']
      end
      # :nocov:

      def title
        @glimr_response['caseTitle']
      end

      def fee_liabilities
        @glimr_response['feeLiabilities'].map do |fee|
          FeeLiability.new(
            fee['feeLiabilityId'].to_i,
            fee['onlineFeeTypeDescription'],
            fee['payableWithUnclearedInPence'].to_i
          )
        end
      end
    end
  end
end
