module Glimr
  module Api
    class PaymentNotificationFailure < StandardError; end
    class Unavailable < StandardError; end
    class CaseNotFound < StandardError; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def call(*args)
        new(*args).call
      end
    end

    def post
      @post ||=
        client.post(path: endpoint, body: request_body.to_query).tap { |resp|
          # Only timeouts and network issues raise errors.
          handle_response_errors(resp)
          @status = resp.status
        }
    rescue Excon::Error => e
      raise Glimr::Api::Unavailable, e
    end

    def ok?
      #:nocov:
      # Only here to ensure devs understand why it might break.
      raise 'Client action (post) must be called before ok?' if @post.blank?
      #:nocov:
      @status == 200
    end

    def response_body
      @body ||= JSON.parse(post.body, symbolize_names: true)
    end

    def request_body
      {}
    end

    private

    def handle_response_errors(resp)
      if resp.status == 404
        raise Glimr::Api::CaseNotFound
      elsif (400..599).cover?(resp.status) && endpoint == '/paymenttaken'
        raise Glimr::Api::PaymentNotificationFailure, resp.status
      elsif (400..599).cover?(resp.status)
        raise Glimr::Api::Unavailable, resp.status
      end
    end

    def client
      @client ||= Excon.new(
        Rails.configuration.glimr_api_url,
        headers: {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        },
        persistent: true
      )
    end
  end
end
