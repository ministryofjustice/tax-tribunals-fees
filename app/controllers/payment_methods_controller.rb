class PaymentMethodsController < ApplicationController
  def update
    payment_method = payment_method_params
    case payment_method
    when 'card'
      redirect_to pay_fee_url(params[:id])
    end
  end

  private

  def payment_method_params
    params.require(:payment_method)
  end
end
