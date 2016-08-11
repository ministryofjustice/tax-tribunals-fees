class ApplicationController < ActionController::Base
  rescue_from Glimr::Api::Unavailable, with: :alert_service_is_not_available
  rescue_from Glimr::Api::PaymentNotificationFailure, with: :alert_glimr_payment_notification_failure
  rescue_from Govpay::Api::Unavailable, with: :alert_service_is_not_available

  protect_from_forgery with: :exception

  before_action :glimr_available

  private

  def alert_service_is_not_available
    @service_is_not_available = true
    render 'pages/start'
  end

  def alert_glimr_payment_notification_failure
    @glimr_payment_notification_error = true
    render 'pages/start'
  end

  def glimr_available
    @glimr_available ||= Glimr.available?
  end
end
