class CreatePayment
  include SimplifiedLogging
  attr_reader :fee, :payment_url

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
    @payment_url = Rails.application.routes.url_helpers.post_pay_fee_url(@fee)
  end

  def call
    create_payment!
    self
  end

  delegate :next_url, to: :create_payment!

  private

  def create_payment!
    @create_payment = GovukPayApiClient::CreatePayment.
      call(fee, payment_url).tap { |p|
        fee.update(govpay_payment_id: p.govpay_id)
    }
  end

end
