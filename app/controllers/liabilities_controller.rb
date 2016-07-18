class LiabilitiesController < ApplicationController
  def pay
    payment = Operations::CreatePayment.new(params[:id]).call

    target = if payment
      payment.payment_url
    else
      root_path
    end
    redirect_to target
    #redirect_to root_path, alert: "Could not connect to our payment gateway - please try again later."
  end

  def post_pay
    Operations::ProcessPayment.new(params[:id]).call do |liability|
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
