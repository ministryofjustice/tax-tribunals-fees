module Glimr
  module Requests
    class Base
      attr_writer :api

      # :nocov:
      # Already tested in multiple specs
      def self.call(*args)
        new(*args).call
      end
      # :nocov:

      def api
        @api || ::Glimr::Api.new
      end
    end
  end
end
