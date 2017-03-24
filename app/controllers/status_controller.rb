class StatusController < ApplicationController
  rescue_from GlimrApiClient::Unavailable, with: :index

  respond_to :json

  def index
    respond_with(Status.check.to_json)
  end
end
