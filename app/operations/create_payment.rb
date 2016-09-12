class CreatePayment
  include SimplifiedLogging
  attr_reader :fee, :return_url

  def self.call(*args)
    new(*args).call
  end

  def initialize(fee_id)
    @fee = Fee.find(fee_id)
    @return_url = Rails.application.routes.url_helpers.post_pay_fee_url(@fee)
  end

  def call
    create_payment!
    self
  end

  delegate :next_url, to: :create_payment!

  private

  def create_payment!
    @create_payment = GovukPayApiClient::CreatePayment.
      call(fee, return_url).tap { |p|
        fee.update(govpay_payment_id: p.payment_id)
    }
  end

end
