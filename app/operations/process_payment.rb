class ProcessPayment
  include SimplifiedLogging

  # Set the environment variable to something falsy (or omit it)
  # in the application's environment to bypass submitting payment
  # success into GLiMR. This allows testing the payment flow over
  # and over again with the same reference, because GLiMR won't
  # consider it paid.
  UPDATE_GLIMR = ENV['UPDATE_GLIMR'] || !Rails.env.development?

  attr_reader :fee, :payment

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
  end

  def call
    process_payment!
    Glimr.fee_paid(fee) if fee.paid? && UPDATE_GLIMR
    log_errors if fee.failed?
    self
  end

  def error_message
    # The fee error message is a copy of the govpay message. If there is a
    # govpay message, that indicates something went wrong.
    payment.message
  end

  private

  def process_payment!
    @payment = Govpay.get_payment(fee)
    fee.update(govpay_payment_status: payment.status,
               govpay_payment_message: payment.message)
  end

  def log_errors
    log_error('payment_processor_fee_failure',
      fee.govpay_payment_status,
      fee.govpay_payment_message)
  end
end
