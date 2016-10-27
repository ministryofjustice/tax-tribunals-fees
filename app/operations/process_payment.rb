class ProcessPayment
  include SimplifiedLogging

  # Set the environment variable to something falsy (or omit it)
  # in the application's environment to bypass submitting payment
  # success into GLiMR. This allows testing the payment flow over
  # and over again with the same reference, because GLiMR won't
  # consider it paid.
  UPDATE_GLIMR = ENV['UPDATE_GLIMR'] || !Rails.env.development?

  attr_reader :fee, :payment, :glimr

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
  end

  def call
    process_payment!

    # TODO: Updating GLiMR to notify it that the fee has been paid
    # should not be done in-process here. Instead, we should add a
    # message to a queue, so that if GLiMR is down for a short
    # period, the notification is done as soon as it is back up.
    # From the users POV, once they've paid, that should be the
    # end of the procedure. Subsequent system issues are our
    # problem, not theirs.
    update_glimr! if fee.paid? && UPDATE_GLIMR

    log_errors if error?
    self
  end

  def error?
    fee.failed? || glimr.try(:error?)
  end

  def error_message
    # The fee error message is a copy of the govpay message.
    payment.message || glimr.try(:error_message)
  end

  private

  def process_payment!
    @payment = GovukPayApiClient::GetStatus.call(fee).tap { |gp|
      fee.update(govpay_payment_status: gp.status,
                 govpay_payment_message: gp.message)
    }
  end

  def update_glimr!
    @glimr = GlimrApiClient::Update.call(fee)
  end

  def log_errors
    log_fee_error if fee.failed?
    log_glimr_error if glimr.try(:error?)
  end

  def log_fee_error
    log_error('payment_processor_fee_failure',
      fee.govpay_payment_status,
      fee.govpay_payment_message)
  end
end
