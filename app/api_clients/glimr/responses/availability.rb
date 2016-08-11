module Glimr
  module Responses
    class Availability
      def initialize(glimr_response)
        @glimr_response = glimr_response
      end

      # :nocov:
      def error?
        false
      end
      # :nocov:

      def available?
        @glimr_response['glimrAvailable'] == 'yes'
      end
    end
  end
end
