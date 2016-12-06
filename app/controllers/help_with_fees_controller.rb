class HelpWithFeesController < ApplicationController
  layout 'payments'

  def show
    @fee = Fee.find(params[:id])
  end

  def update
    @fee = Fee.find(params[:id])
  end
end
