module Operations
  class ProcessPayment
    attr_reader :liability_id

    def initialize(liability_id)
      @liability_id = liability_id
    end

    def call(&block)
      yield liability if verify_payment_status && post_glimr_fee_payment
    end

    private

    def verify_payment_status
      if payment.error?
        Rails.logger.error "Error getting payment status: #{payment.error_code} - #{payment.error_message}"
        return false
      end

      liability.update(
        govpay_payment_status: payment.status,
        govpay_payment_message: payment.message
      )

      true
    end

    def post_glimr_fee_payment
      # Set this environment variable to something falsy (or omit it)
      # in the application's environment to bypass submitting payment
      # success into GLiMR. This allows testing the payment flow over
      # and over again with the same reference, because GLiMR won't
      # consider it paid.
      return true unless ENV['GLIMR_SUBMIT_PAYMENT_SUCCESS']

      glimr_status = Glimr.fee_paid(liability)
      if glimr_status.error?
        Rails.logger.error "Error pushing payment status to GLiMR: #{glimr_status.error_code} - #{glimr_status.error_message}"
        return false
      end

      true
    end

    def liability
      @liability ||= FeeLiability.find(liability_id)
    end

    def payment
      @payment ||= Govpay.get_payment(liability)
    end
  end
end
