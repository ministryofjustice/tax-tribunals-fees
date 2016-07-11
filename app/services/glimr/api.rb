module Glimr
  class Api
    include HTTParty

    base_uri Rails.configuration.glimr_api_url
    default_timeout 8 # seconds
    format :json
    headers Accept: 'application/json'

    def post(endpoint, body)
      self.class.post(endpoint, body: body)
    rescue SocketError, Timeout::Error => e
      Responses::ApiError.new(e)
    end
  end
end
