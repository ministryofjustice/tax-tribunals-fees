require 'rails_helper'
require 'support/shared_examples_for_govpay'
require 'support/create_a_fee'

RSpec.feature 'Pay for a case' do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
  end

  describe '#post_pay' do
    include_examples 'govpay payment response', fee.govpay_payment_id

    let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }

    before do
      allow(GlimrApiClient::Update).to receive(:call)
      fee.update(govpay_payment_id: govpay_payment_id)
    end

    context 'a successful payment' do
      before do
        visit post_pay_fee_url(fee)
      end

      it 'updates the case in GLiMR' do
        expect(GlimrApiClient::Update).to have_received(:call).with(an_instance_of(Fee))
      end

      it 'shows the case reference' do
        expect(page).to have_text(fee.case_reference)
      end

      it 'shows the payment id' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text(fee.govpay_payment_id.upcase)
      end

      it 'shows the case title' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text(fee.case_title)
      end
    end

    context 'failed payment' do
      def failure
        {
          'state' =>
          {
            'status' => 'failed',
            'message' => '3D secure failed'
          }
        }.to_json
      end

      include_examples 'govpay payment response', fee.govpay_payment_id

      before do
        fee.update(govpay_payment_id: govpay_payment_id)
      end

      it 'does not try to update glimr' do
        expect(GlimrApiClient::Update).not_to receive(:call)
        visit post_pay_fee_url(fee)
      end

      it 'notifies the user' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('we couldn’t take your payment')
      end
    end

    context 'govpay fails' do
      # This signals that a fee has been paid. Not using fixtures due to the
      # inability to explicitly pass `let` blocks into shared examples outside
      # of `it` declarations.
      before do
        fee.update(govpay_payment_id: govpay_payment_id)
      end

      include_examples 'govpay post_pay returns a 500', fee.govpay_payment_id

      it 'does not update glimr' do
        visit post_pay_fee_url(fee)
        expect(GlimrApiClient::Update).not_to receive(:call)
      end

      it 'notifies the user' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('We couldn’t find your payment details.')
      end
    end

    context 'govpay payment status times out' do
      include_examples 'govpay payment status times out', fee.govpay_payment_id

      it 'does not try to update glimr' do
        expect(GlimrApiClient::Update).not_to receive(:call)
        visit post_pay_fee_url(fee)
      end

      it 'alerts the user to the failure' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('We couldn’t find your payment details.')
      end
    end

    context 'glimr update fails' do
      # include_examples 'glimr fee_paid returns a 500'
      before do
        allow(GlimrApiClient::Update).to receive(:call).and_raise(GlimrApiClient::RequestError)
      end

      # TODO: This issue will go away, once we move notifying GLiMR about
      # successful payments to a background queue
      it 'does not handle the exception from the GlimrApiClient gem' do
        expect {
          visit post_pay_fee_url(fee)
        }.to raise_error(GlimrApiClient::RequestError)
      end
    end
  end

  # A successful call to `#pay` is tested with a request spec as it involves a
  # redirect to the Gov UK Payment gateway.
  describe '#pay' do
    context 'the GovPay API returns a 404' do
      include_examples 'govpay returns a 404', fee

      it 'does not update glimr' do
        expect(GlimrApiClient::Update).not_to receive(:call)
        visit post_pay_fee_url(fee)
      end

      it 'alerts the user the service is unavailable' do
        visit pay_fee_url(fee)
        expect(page).to have_text('The service is currently unavailable')
      end
    end

    context 'govpay times out' do
      include_examples 'govpay create payment times out', fee

      it 'does not update glimr' do
        expect(GlimrApiClient::Update).not_to receive(:call)
        visit post_pay_fee_url(fee)
      end

      it 'alerts the user the service is unavailable' do
        visit pay_fee_url(fee)
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end
end
