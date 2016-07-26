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

    unless operation.error? || operation.failed?
      render 'post_pay_success'
    else
      render 'post_pay_error'
    end
  end
end
