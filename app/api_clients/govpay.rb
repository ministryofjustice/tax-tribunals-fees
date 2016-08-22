require 'govpay/api'
require 'govpay/requests/create_payment'
require 'govpay/requests/get_payment_status'
require 'govpay/responses/payment_created'
require 'govpay/responses/payment_status'

module Govpay
  module_function

  def create_payment(fee)
    Requests::CreatePayment.call(fee)
  end

  def get_payment(fee)
    Requests::GetPaymentStatus.call(fee)
  end
end
