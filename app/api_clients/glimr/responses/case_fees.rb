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
        @glimr_response.fetch(:caseTitle)
      end

      def fee_liabilities
        @glimr_response.fetch(:feeLiabilities).map do |fee|
          FeeLiability.new(
            fee.fetch(:feeLiabilityId).to_i,
            fee.fetch(:onlineFeeTypeDescription),
            fee.fetch(:payableWithUnclearedInPence).to_i
          )
        end
      end
    end
  end
end
