module Govpay
  class Api
    class Unavailable < StandardError; end
    include HTTParty

    base_uri Rails.configuration.govpay_api_url
    default_timeout 4 # seconds
    format :json
    headers(
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{Rails.configuration.govpay_api_key}"
    )

    def get(endpoint)
      self.class.get(endpoint)
    rescue SocketError, Timeout::Error => e
      raise Govpay::Api::Unavailable, e
    end

    def post(endpoint, body)
      self.class.post(endpoint, body: body)
    rescue SocketError, Timeout::Error => e
      raise Govpay::Api::Unavailable, e
    end
  end
end
