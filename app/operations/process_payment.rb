class ProcessPayment
  include SimplifiedLogging

  # Set the environment variable to something falsy (or omit it)
  # in the application's environment to bypass submitting payment
  # success into GLiMR. This allows testing the payment flow over
  # and over again with the same reference, because GLiMR won't
  # consider it paid.
  UPDATE_GLIMR = ENV['UPDATE_GLIMR'] || !Rails.env.development?

  attr_reader :liability, :payment, :glimr

  def initialize(liability_id)
    @liability = Liability.find(liability_id)
    @payment = Govpay.get_payment(@liability).tap { |gp|
      @liability.update(govpay_payment_status: gp.status,
                        govpay_payment_message: gp.message)
    }
    if @liability.paid? && !@payment.error? && UPDATE_GLIMR
      @glimr = Glimr.fee_paid(liability)
    end
    log_errors if error?
  end

  def error?
    payment.error? || liability.failed? || glimr.try(:error?)
  end

  def error_message
    # The liability error message is a copy of the govpay message.
    payment.message || glimr.try(:error_message)
  end

  private

  def log_errors
    log_liability_error if liability.failed?
    log_govpay_error if payment.error?
    log_glimr_error if glimr.try(:error?)
  end

  def log_liability_error
    log_error('payment_processor_liability_failure',
      liability.govpay_payment_status,
      liability.govpay_payment_message)
  end

  def log_govpay_error
    log_error('payment_processor_govpay_error',
      payment.error_code,
      payment.error_message)
  end

  def log_glimr_error
    log_error('payment_processor_glimr_error',
      glimr.error_code,
      glimr.error_message)
  end
end
