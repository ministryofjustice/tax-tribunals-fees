class PaymentsController < ApplicationController
  def update
    payment_method = payment_params
    case payment_method
    when 'card'
      redirect_to pay_fee_url(params[:id])
    when 'help_with_fees'
      redirect_to help_with_fees_url(params[:id])
    end
  end

  def show
    @fee = Fee.find(params[:id])
  end

  private

  def payment_params
    params.require(:payment_method)
  end
end
