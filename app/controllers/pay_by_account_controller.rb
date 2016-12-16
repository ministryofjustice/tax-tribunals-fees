class PayByAccountController < ApplicationController
  rescue_from GlimrApiClient::PayByAccount::AccountNotFound,
    GlimrApiClient::PayByAccount::InvalidAccountAndConfirmation,
    with: :account_not_found
  include SimplifiedLogging

  def show
    @fee = Fee.find(params[:id])
  end

  def update
    @fee = Fee.find(params[:id])
    ProcessPayByAccount.call(@fee.id, pay_by_account_params)
    redirect_to payment_url(@fee)
  end

  def account_not_found(exception)
    log_error(self.class.name, 'N/A', exception)
    flash[:alert] = t('.account_not_found')
    @fee = Fee.find(params[:id])
    render 'show'
  end

  private

  def pay_by_account_params
    p = params.require(
      [:pay_by_account_reference, :pay_by_account_confirmation]
    )
    { reference: p.first, confirmation: p.last }
  end
end
