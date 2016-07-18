class PagesController < ApplicationController
  rescue_from Glimr::Api::Unavailable, with: :service_not_available
  include HighVoltage::StaticPage

  before_action :glimr_available

  private

  def service_not_available
    @glimr_available = false
    render 'start'
  end

  def glimr_available
    @glimr_available ||= Glimr.available?
  end
end
