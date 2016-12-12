class ProcessPayByAccount
  include SimplifiedLogging

  attr_reader :fee,
    :payment,
    :glimr,
    :pay_by_account_params

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id, pay_by_account_params)
    @fee = Fee.find(fee_id)
    @pay_by_account_params = pay_by_account_params
  end

  def call
    process_payment!
    # This only catches errors where the API returns a response body with the
    # key `error`. Errors raised by the gem (i.e.
    # GlimrApiClient::PayByAccount::AccountNotFound) are rescued at the
    # controller level.
    log_errors if error?
    fee.update_columns(
      pay_by_account_reference: pay_by_account_params[:reference],
      pay_by_account_confirmation: pay_by_account_params[:confirmation]
    )
    self
  end

  def error?
    fee.failed? || glimr.try(:error?)
  end

  private

  def process_payment!
    @glimr = GlimrApiClient::PayByAccount.call(
      feeLiabilityId: fee.glimr_id,
      pbaAccountNumber: pay_by_account_params[:reference],
      pbaConfirmationCode: pay_by_account_params[:confirmation],
      pbaTransactionReference: fee.case_reference,
      amountToPayInPence: fee.amount
    )
  end
end
