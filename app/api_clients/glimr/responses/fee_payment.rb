module Glimr
  module Responses
    class FeePayment
      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      def error?
        false
      end
    end
  end
end
