module Glimr
  module Requests
    class Available
      include Glimr::Api

      def call
        unless ok? && available?
          raise Glimr::Api::Unavailable, response_body
        else
          self
        end
      end

      def available?
        response_body[:glimrAvailable] == 'yes'
      end

      private

      def endpoint
        '/glimravailable'
      end
    end
  end
end
