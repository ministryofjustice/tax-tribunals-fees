module Glimr
  module Responses
    class CaseFees
      # using 'defined?' here suppresses a warning if we try to load
      # this module multiple times
      unless defined?(FeeLiability)
        FeeLiability = Struct.new(:glimr_id, :description, :amount)
      end

      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      def title
        @glimr_response[:caseTitle]
      end

      def fee_liabilities
        @glimr_response[:feeLiabilities].map do |fee|
          FeeLiability.new(
            fee[:feeLiabilityId].to_i,
            fee[:onlineFeeTypeDescription],
            fee[:payableWithUnclearedInPence].to_i
          )
        end
      end
    end
  end
end
