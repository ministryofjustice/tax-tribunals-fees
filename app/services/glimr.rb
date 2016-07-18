require 'glimr/api'
require 'glimr/requests/base'
require 'glimr/requests/case_fees'
require 'glimr/requests/fee_paid'
require 'glimr/responses/api_error'
require 'glimr/responses/case_fees'
require 'glimr/responses/case_not_found'
require 'glimr/responses/fee_payment'

module Glimr
  module_function

  def find_case(case_reference, confirmation_code)
    Requests::CaseFees.call(
      case_reference: case_reference,
      confirmation_code: confirmation_code
    )
  end

  def available?
    Requests::Available.call.available?
  end
end
