class ProcessPayment
  attr_reader :liability

  def initialize(liability_id)
    @liability = FeeLiability.find(liability_id)
  end

  def payment
    @payment ||= Govpay.get_payment(liability).tap { |p|
      liability.update(
        govpay_payment_status: p.status,
        govpay_payment_message: p.message
      )

      if p.error?
        Rails.logger.error(
          {
            source: 'payment_processor_get_payment_error',
            error_code: p.error_code,
            error_message: p.error_message
          }.to_a.map{ |x| x.join('=') }.join(' ')
        )
      elsif liability.failed?
        Rails.logger.error(
          {
            source: 'payment_processor_fee_liability_not_paid',
            payment_status: liability.govpay_payment_status,
            payment_message: liability.govpay_payment_message
          }.to_a.map{ |x| x.join('=') }.join(' ')
        )
      else
        notifiy_glimr_fee_has_been_paid!
      end
    }
  end

  def glimr
    @glimr ||= Glimr.fee_paid(liability)
  end

  def glimr_error?
    glimr.error?
  end

  delegate :error?, to: :payment
  delegate :failed?, to: :liability

  private

  def notifiy_glimr_fee_has_been_paid!
    # Set this environment variable to something falsy (or omit it)
    # in the application's environment to bypass submitting payment
    # success into GLiMR. This allows testing the payment flow over
    # and over again with the same reference, because GLiMR won't
    # consider it paid.
    return true unless ENV['GLIMR_SUBMIT_PAYMENT_SUCCESS']

    if glimr_error?
      Rails.logger.error(
        {
          source: 'payment_processor_glimr_notificaiton',
          error_code: glimr.error_code,
          error_message: glimr.error_message
        }.to_a.map{ |x| x.join('=') }.join(' ')
      )
    end
  end
end
