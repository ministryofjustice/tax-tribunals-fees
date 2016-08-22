class CreatePayment
  include SimplifiedLogging
  attr_reader :fee

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
  end

  def payment
    @payment ||= Govpay.create_payment(fee).tap { |p|
      fee.update(govpay_payment_id: p.govpay_id)
    }
  end

  delegate :payment_url, to: :payment
end
