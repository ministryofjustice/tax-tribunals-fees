class ProcessHelpWithFees
  include SimplifiedLogging

  attr_reader :fee, :payment, :glimr

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
  end

  def call
    process_payment!
    log_errors if error?
    self
  end

  def error?
    fee.failed? || glimr.try(:error?)
  end

  private

  def process_payment!
    @glimr = GlimrApiClient::HwfRequested.call(
      feeLiabilityId: fee.glimr_id,
      hwfRequestReference: fee.help_with_fees_reference,
      amountToPayInPence: fee.amount
    )
  end
end
