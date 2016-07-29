class ApplicationController < ActionController::Base
  rescue_from Glimr::Api::Unavailable, with: :service_not_available
  protect_from_forgery with: :exception

  before_action :glimr_available

  private

  def service_not_available
    @glimr_available = false
    render 'pages/start'
  end

  def glimr_available
    @glimr_available ||= Glimr.available?
  end
end
