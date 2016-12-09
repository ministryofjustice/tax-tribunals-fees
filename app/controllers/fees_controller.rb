class FeesController < ApplicationController
  def pay
    operation = CreatePayment.call(params[:id])
    redirect_to operation.next_url
  rescue GovukPayApiClient::Unavailable
    redirect_to root_path, alert: t('apis.service_unavailable')
  end

  def post_pay
    operation = ProcessPayment.call(params[:id])

    @fee = operation.fee
    if operation.error?
      flash[:error] = operation.error_message || t('.payment_error')
      render 'post_pay_error' and return
    end
    redirect_to payment_url(@fee)
  rescue GovukPayApiClient::Unavailable
    redirect_to root_path, alert: t('apis.payment_status_unavailable')
  end
end
