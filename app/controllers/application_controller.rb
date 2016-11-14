class ApplicationController < ActionController::Base
  rescue_from GlimrApiClient::Unavailable, with: :alert_glimr_is_not_available
  rescue_from GlimrApiClient::Case::InvalidCaseNumber, with: :case_not_found

  protect_from_forgery with: :exception

  before_action :glimr_available

  private

  def case_not_found
    @case_not_found = true
    render 'pages/start'
  end

  def alert_glimr_is_not_available
    @glimr_is_not_available = true
    render 'pages/start'
  end

  def glimr_available
    @glimr_available ||= GlimrApiClient::Available.call.available?
  end
end
