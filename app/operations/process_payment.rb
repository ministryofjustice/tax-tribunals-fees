class ProcessPayment
  include SimplifiedLogging

  # Set the environment variable to something falsy (or omit it)
  # in the application's environment to bypass submitting payment
  # success into GLiMR. This allows testing the payment flow over
  # and over again with the same reference, because GLiMR won't
  # consider it paid.
  UPDATE_GLIMR = ENV['UPDATE_GLIMR'] || !Rails.env.development?

  attr_reader :fee, :payment, :glimr

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
    @payment = Govpay.get_payment(@fee).tap { |gp|
      @fee.update(govpay_payment_status: gp.status,
                  govpay_payment_message: gp.message)
    }
    if @fee.paid? && !@payment.error? && UPDATE_GLIMR
      @glimr = Glimr.fee_paid(fee)
    end
    log_errors if error?
  end

  def error?
    payment.error? || fee.failed? || glimr.try(:error?)
  end

  def error_message
    # The fee error message is a copy of the govpay message.
    payment.message || glimr.try(:error_message)
  end

  private

  def log_errors
    log_fee_error if fee.failed?
    log_govpay_error if payment.error?
    log_glimr_error if glimr.try(:error?)
  end

  def log_fee_error
    log_error('payment_processor_fee_failure',
      fee.govpay_payment_status,
      fee.govpay_payment_message)
  end

  def log_govpay_error
    log_error('payment_processor_govpay_error',
      payment.error_code,
      payment.error_message)
  end
end
