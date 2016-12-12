class PaymentsController < ApplicationController
  def update
    payment_method = payment_params
    case payment_method
    when 'card'
      redirect_to pay_fee_url(params[:id])
    when 'help_with_fees'
      redirect_to help_with_fees_url(params[:id])
    when 'authorised_account'
      redirect_to pay_by_account_url(params[:id])
    end
  end

  def show
    @fee = Fee.find(params[:id])
    @paid_via_copy, @reference = payment_response(@fee)
  end

  private

  def payment_response(fee)
    if fee.govpay_payment_status.present?
      [I18n.t('.payments.paid_via_card'),
       fee.govpay_payment_id.upcase]
    elsif fee.help_with_fees_reference.present?
      [I18n.t('.payments.paid_via_help_with_fees'),
       fee.help_with_fees_reference]
    elsif fee.pay_by_account_reference.present?
      [I18n.t('.payments.paid_via_account'),
       fee.pay_by_account_reference]
    end
  end

  def payment_params
    params.require(:payment_method)
  end
end
