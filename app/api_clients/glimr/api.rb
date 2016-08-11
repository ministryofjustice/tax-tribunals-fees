module Glimr
  class Api
    class Unavailable < StandardError; end

    def post(endpoint, body)
      RestClient.post(
        "#{Rails.configuration.glimr_api_url}#{endpoint}",
        body,
        content_type: :json,
        accept: :json
      )
    rescue SocketError, Timeout::Error => e
      raise Glimr::Api::Unavailable, e
    end
  end
end
