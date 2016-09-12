require 'rails_helper'
require 'support/shared_examples_for_govpay'
require 'support/shared_examples_for_glimr'
require 'support/create_a_fee'

RSpec.describe 'Pay for a case', type: :request do
  # `#post_pay` and failed calls to `#pay` are tested with feature specs as
  # they do not involve redirects to the govuk payment gateway and feature
  # specs are otherwise somewhat more declarative and easier to deal with.
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  include_examples 'a case fee of £20 is due', case_number, confirmation_code
  include_examples 'govpay create payment response', fee, fee.govpay_payment_id

  describe '#pay' do
    context 'succeeds' do
      it 'redirects to the govpay payment URL' do
        get "/fees/#{fee.id}/pay"
        expect(response).to redirect_to(
          'https://www-integration-2.pymnt.uk/secure/94b35000-37f2-44e6-a2f5-c0193ca1e98a'
        )
      end
    end
  end
end
