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
    ProcessPayment.new(params[:id]).call do |liability|
      @liability = liability
      @case_request = liability.case_request

      if @liability.paid?
        render 'post_pay_success'
      else
        render 'post_pay_error'
      end

      return
    end

    redirect_to root_path, alert: "Could not connect to our payment gateway - please try again later."
  end
end
