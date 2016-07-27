require 'govpay/api'
require 'govpay/requests/base'
require 'govpay/requests/create_payment'
require 'govpay/requests/get_payment_status'
require 'govpay/responses/api_error'
require 'govpay/responses/create_payment_failed'
require 'govpay/responses/payment_created'
require 'govpay/responses/payment_status'

module Govpay
  module_function

  def create_payment(fee_liability)
    Requests::CreatePayment.call(fee_liability)
  end

  def get_payment(fee_liability)
    Requests::GetPaymentStatus.call(fee_liability)
  end
end
