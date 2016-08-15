module Glimr
  module Requests
    class Available
      include Glimr::Api

      def call
        if ok? && available?
          self
        else
          raise Glimr::Api::Unavailable, response_body
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
