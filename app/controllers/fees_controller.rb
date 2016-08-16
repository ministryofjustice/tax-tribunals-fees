class FeesController < ApplicationController
  def pay
    operation = CreatePayment.new(params[:id])

    target = if operation.error?
               flash[:alert] = t('apis.service_unavailable')
               root_path
             else
               operation.payment_url
             end

    redirect_to target
  rescue Govpay::Api::Unavailable
    flash[:alert] = t('apis.service_unavailable')
    redirect_to root_path
  end

  def post_pay
    operation = ProcessPayment.new(params[:id])

    @fee = operation.fee
    if operation.error?
      flash[:error] = operation.error_message || t('.payment_error')
      render 'post_pay_error'
    else
      render 'post_pay_success'
    end
  rescue Govpay::Api::Unavailable
    @fee ||= Fee.find(params[:id])
    render 'post_pay_error'
  end

  private

  def govpay_is_not_available
    render 'post_pay_error'
  end
end
