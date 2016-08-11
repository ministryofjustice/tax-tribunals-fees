require 'rails_helper'
require 'support/shared_examples_for_govpay'
require 'support/shared_examples_for_glimr'

RSpec.describe 'Pay for a case', type: :request do
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  include_examples 'a case fee of £20 is due', case_number, confirmation_code
  include_examples 'govpay payment response'

  # The fee is set up in the shared example
  describe '#pay' do
    context 'the GovPay API returns a valid response' do
      it 'redirects to the govpay payment URL' do
        get "/fees/#{fee.id}/pay"
        expect(response).to redirect_to(
          'https://www-integration-2.pymnt.uk/secure/94b35000-37f2-44e6-a2f5-c0193ca1e98a'
        )
      end
    end

    context 'the GovPay API returns a 404' do
      include_examples 'govpay returns a 404'

      it 'redirects to the govpay payment URL' do
        get "/fees/#{fee.id}/pay"
        expect(response).to redirect_to(root_url)
      end
    end

    context 'govpay times out' do
      include_examples 'govpay times out'

      it 'alerts the user' do
        get "/fees/#{fee.id}/pay"
        expect(response.body).to include('The service is currently unavailable')
      end
    end
  end

  # TODO: spec the unhappy path for the race condition whereby the fee
  # fee gets called early and does not yet have a govpay_payment_id
  describe '#post_pay' do
    context 'successful payment' do
      include_examples 'report payment taken to glimr'

      before do
        get "/fees/#{fee.id}/pay"
      end

      it 'tells the user their payment was taken' do
        get "/fees/#{fee.id}/post_pay"
        fee.reload
        expect(response.body).to include(fee.case_reference)
        expect(response.body).to match(fee.case_title)
        expect(response.body).to include(fee.govpay_payment_id.upcase)
      end
    end

    context 'failed payment' do
      let(:post_pay_response) {
        {
          'state' =>
            {
              'status' => 'failed',
              'message' => '3D secure failed'
            }
        }.to_json
      }

      before do
        get "/fees/#{fee.id}/pay"
      end

      it 'does not try to update glimr' do
        expect(Glimr).not_to receive(:fee_paid)
        get "/fees/#{fee.id}/post_pay"
      end

      it 'alerts the user to the failure and reason' do
        get "/fees/#{fee.id}/post_pay"
        fee.reload
        expect(response.body).to include('try making the payment again')
        expect(response.body).to include('3D secure failed')
        expect(response.body).to include('we couldn’t take your payment')
      end
    end

    context 'govpay fails' do
      include_examples 'govpay payment response'
      include_examples 'govpay post_pay returns a 500'

      before do
        get "/fees/#{fee.id}/pay"
      end

      it 'does not try to update glimr' do
        expect(Glimr).not_to receive(:fee_paid)
        get "/fees/#{fee.id}/post_pay"
      end

      it 'alerts the user to the failure and reason' do
        get "/fees/#{fee.id}/post_pay"
        fee.reload
        expect(response.body).to include('try making the payment again')
        expect(response.body).to include('Govpay is not working')
        expect(response.body).to include('we couldn’t take your payment')
      end
    end

    context 'govpay times out' do
      include_examples 'govpay times out'

      before do
        get "/fees/#{fee.id}/pay"
      end

      it 'does not try to update glimr' do
        expect(Glimr).not_to receive(:fee_paid)
        get "/fees/#{fee.id}/post_pay"
      end

      it 'alerts the user to the failure and reason' do
        expect(response.body).to include('The service is currently unavailable')
        get "/fees/#{fee.id}/post_pay"
      end
    end

    context 'glimr update fails' do
      include_examples 'govpay payment response'
      include_examples 'glimr fee_paid returns a 500'

      before do
        get "/fees/#{fee.id}/pay"
      end

      it 'alerts the user to the failure and reason' do
        get "/fees/#{fee.id}/post_pay"
        fee.reload
        expect(response.body).
          to include('error updating your case with your payment details')
      end
    end
  end
end
