class HealthcheckController < ApplicationController
  rescue_from GlimrApiClient::Unavailable, with: :index

  respond_to :json

  def index
    respond_with(Healthcheck.check.to_json)
  end
end
