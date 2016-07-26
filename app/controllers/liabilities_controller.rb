class LiabilitiesController < ApplicationController
  def pay
    operation = CreatePayment.new(params[:id])

    target = unless operation.error?
               operation.payment_url
             else
               flash[:alert] = t('.govpay_api_error')
               root_path
             end

    redirect_to target
  end

  def post_pay
    operation = ProcessPayment.new(params[:id])
    @liability = operation.liability
    @case_request = @liability.case_request

    if operation.error? || operation.failed? || operation.glimr_error?
      flash[:error] = @liability.govpay_payment_message || t('.payment_error')
      render 'post_pay_error'
    else
      render 'post_pay_success'
    end
  end
end
