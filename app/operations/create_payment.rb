class CreatePayment
  include SimplifiedLogging
  attr_reader :fee

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
  end

  def payment
    @payment ||= Govpay.create_payment(fee).tap { |p|
      if p.error?
        log_error('create_payment_govpay_error',
          p.error_code,
          p.error_message)
      else
        fee.update(govpay_payment_id: p.govpay_id)
      end
    }
  end

  delegate :error?, :payment_url, to: :payment
end
