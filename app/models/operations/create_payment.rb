module Operations
  class CreatePayment
    attr_reader :liability_id

    def initialize(liability_id)
      @liability_id = liability_id
    end

    def call
      if payment.error?
        Rails.logger.error "Failed to create GOV.UK payment: #{payment.error_code} - #{payment.error_message}"
      else
        @liability.update(govpay_payment_id: payment.govpay_id)
        payment
      end
    end

    private

    def liability
      @liability ||= FeeLiability.find(liability_id)
    end

    def payment
      @payment ||= Govpay.create_payment(liability)
    end
  end
end
