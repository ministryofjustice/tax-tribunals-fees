module Glimr
  module Api
    class PaymentNotificationFailure < StandardError; end
    class Unavailable < StandardError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def call(*args)
        new(*args).call
      end
    end

    def post
      @post ||= RestClient.post(
        "#{Rails.configuration.glimr_api_url}#{endpoint}",
        request_body,
        content_type: :json,
        accept: :json
      )
    rescue RestClient::Exception => e
      if endpoint == '/paymenttaken'
        raise Glimr::Api::PaymentNotificationFailure, e
      else
        raise Glimr::Api::Unavailable, e
      end
    end

    def ok?
      post.code == 200
    end

    def response_body
      @body ||= JSON.parse(post.body, symbolize_names: true)
    end

    def request_body
      {}
    end
  end
end
