class FeesController < ApplicationController
  def pay
    operation = CreatePayment.new(params[:id])
    redirect_to operation.payment_url
  rescue Govpay::Api::Unavailable
    redirect_to root_path, alert: t('apis.service_unavailable')
  end

  def post_pay
    operation = ProcessPayment.call(params[:id])

    @fee = operation.fee
    if operation.error?
      flash[:error] = operation.error_message || t('.payment_error')
      render 'post_pay_error'
    else
      render 'post_pay_success'
    end
  rescue Govpay::Api::Unavailable
    redirect_to root_path, alert: t('apis.payment_status_unavailable')
  end
end
