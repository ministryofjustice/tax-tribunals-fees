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

    context 'the GovPay API returns a 404' do
      include_examples 'govpay returns a 404'

      it 'redirects to the govpay payment URL' do
        get "/liabilities/#{liability.id}/pay"
        expect(response).to redirect_to(root_url)
      end
    end
  end

  # TODO: spec the unhappy path for the race condition whereby the fee
  # liability gets called early and does not yet have a govpay_payment_id
  describe '#post_pay' do
    context 'successful payment' do
      include_examples 'report payment taken to glimr'

      before do
        get "/liabilities/#{liability.id}/pay"
      end

      it 'tells the user their payment was taken' do
        get "/liabilities/#{liability.id}/post_pay"
        liability.reload
        expect(response.body).to include(liability.case_request.case_reference)
        expect(response.body).to match(liability.case_request.case_title)
        expect(response.body).to include('Payment successful')
        expect(response.body).to include('Your payment reference is')
        expect(response.body).to include(liability.govpay_payment_id.upcase)
      end
    end

    context 'failed payment' do
      let(:post_pay_response) {
        { 'state' =>
          {
          'status' => 'failed',
          'message' => '3D secure failed'
          }
        }.to_json
      }

      before do
        get "/liabilities/#{liability.id}/pay"
      end

      it 'does not try to update glimr' do
        expect(Glimr).not_to receive(:fee_paid)
        get "/liabilities/#{liability.id}/post_pay"
      end

      it 'alerts the user to the failure and reason' do
        get "/liabilities/#{liability.id}/post_pay"
        liability.reload
        expect(response.body).to include('try making the payment again')
        expect(response.body).to include('3D secure failed')
        expect(response.body).to include('we couldn’t take your payment')
      end
    end

    context 'govpay fails' do
      include_examples 'govpay payment response'
      include_examples 'govpay post_pay returns a 500'

      before do
        get "/liabilities/#{liability.id}/pay"
      end

      it 'does not try to update glimr' do
        expect(Glimr).not_to receive(:fee_paid)
        get "/liabilities/#{liability.id}/post_pay"
      end

      it 'alerts the user to the failure and reason' do
        get "/liabilities/#{liability.id}/post_pay"
        liability.reload
        expect(response.body).to include('try making the payment again')
        expect(response.body).to include('Govpay is not working')
        expect(response.body).to include('we couldn’t take your payment')
      end
    end
  end
end
