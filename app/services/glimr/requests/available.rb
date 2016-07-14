module Glimr
  module Requests
    class Available < Base
      def call
        if response.success?
          Responses::Availability.new(response)
        else
          # This is being tested by the feature, but simplecov does not
          # seem to be able to work that out.
          # :nocov:
          Responses::Availability.new('glimrAvailable' => 'no')
          # :nocov:
        end
      end

      private

      def response
        @response ||= api.post(endpoint, {})
      end

      def endpoint
        '/glimravailable'
      end
    end
  end
end
