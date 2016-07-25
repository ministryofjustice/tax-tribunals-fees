require 'rails_helper'
require 'shared_examples_for_govpay'
require 'shared_examples_for_glimr'

RSpec.describe LiabilitiesController do
  include_examples 'govpay payment response'

  # The liability is set up in the shared example
  describe '#pay' do
    context 'the GovPay API returns a valid response' do
      it 'redirects to the govpay payment URL' do
        get "/liabilities/#{liability.id}/pay"
        expect(response).to redirect_to(
          'https://www-integration-2.pymnt.uk/secure/94b35000-37f2-44e6-a2f5-c0193ca1e98a'
        )
      end
    end
  end

  # TODO: spec the unhappy path for the race condition whereby the fee
  # liability gets called early and does not yet have a govpay_payment_id
  describe '#post_pay' do
    include_examples 'payment taken'

    before do
        get "/liabilities/#{liability.id}/pay"
    end

    context 'payment has been successful' do
      it 'redirects to the govpay payment URL' do
        get "/liabilities/#{liability.id}/post_pay"
        liability.reload
        expect(response.body).to include(liability.case_request.case_reference)
        expect(response.body).to match(liability.case_request.case_title)
        expect(response.body).to include('Payment successful')
        expect(response.body).to include('Your payment reference is')
        expect(response.body).to include(liability.govpay_payment_id.upcase)
      end
    end
  end
end
