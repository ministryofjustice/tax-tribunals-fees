module Glimr
  module Responses
    class CaseNotFound
      class BadResponse < StandardError; end

      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      def error?
        true
      end

      def error_code
        @glimr_response['glimrerrorcode']
      end

      def error_message
        @glimr_response['message']
      end
    end
  end
end
