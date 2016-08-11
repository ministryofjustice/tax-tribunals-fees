class FeesController < ApplicationController
  def pay
    operation = CreatePayment.new(params[:id])

    target = if operation.error?
               flash[:alert] = t('.govpay_api_error')
               root_path
             else
               operation.payment_url
             end

    redirect_to target
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
  end
end
