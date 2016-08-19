module Govpay
  module Api
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
      @post ||=
        client.post(path: endpoint, body: request_body.to_json).tap { |resp|
          # Only timeouts and network issues raise errors.
          handle_response_errors(resp)
          @status = resp.status
          @body = resp.body || {}.to_json
        }
    rescue Excon::Error => e
      raise Unavailable, e
    end

    def get
      @get ||=
        client.get(path: endpoint, body: request_body.to_json).tap { |resp|
          # Only timeouts and network issues raise errors.
          handle_response_errors(resp)
          @status = resp.status
          @body = resp.body || {}.to_json
        }
    rescue Excon::Error => e
      raise Unavailable, e
    end

    def ok?
      #:nocov:
      if @post.blank? && @get.blank?
        raise 'Client action (post || get) must be called before ok?'
      end
      #:nocov:
      [200, 201].include?(@status)
    end

    def response_body
      @response_body ||= JSON.parse(@body, symbolize_names: true)
    end

    def request_body
      {}
    end

    private

    def handle_response_errors(resp)
      if (400..599).cover?(resp.status)
        raise Unavailable, resp.status
      end
    end

    def client
      @client ||= Excon.new(
        Rails.configuration.govpay_api_url,
        headers: {
          'Authorization' => "Bearer #{Rails.configuration.govpay_api_key}",
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        },
        persistent: true
      )
    end
  end
end
