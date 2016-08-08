class CreatePayment
  include SimplifiedLogging
  attr_reader :liability

  def initialize(liability_id)
    @liability = Liability.find(liability_id)
  end

  def payment
    @payment ||= Govpay.create_payment(liability).tap { |p|
      if p.error?
        log_error('create_payment_govpay_error',
          p.error_code,
          p.error_message)
      else
        liability.update(govpay_payment_id: p.govpay_id)
      end
    }
  end

  delegate :error?, :payment_url, to: :payment
end
