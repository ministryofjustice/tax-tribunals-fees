class CreatePayment
  attr_reader :liability, :payment

  def initialize(liability_id)
    @liability = FeeLiability.find(liability_id)
  end

  def payment
    @payment ||= Govpay.create_payment(liability).tap { |p|
      if p.error?
        Rails.logger.error(
          {
            source: 'create_payment',
            error_code: payment.error_code,
            error_message: payment.error_message
          }.to_a.map{ |x| x.join('=') }.join(' ')
        )
      else
        liability.update(govpay_payment_id: p.govpay_id)
      end
    }
  end

  delegate :error?, :payment_url, to: :payment
end
