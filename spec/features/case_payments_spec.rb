require 'rails_helper'
require 'support/create_a_fee'

RSpec.feature 'Pay for a case' do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
    allow(GovukPayApiClient::GetStatus).to receive(:call).and_return(payment_status)
  end

  describe '#post_pay' do
    let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }
    let(:payment_status) { OpenStruct.new(status: 'success') }

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
      let(:payment_status) { OpenStruct.new(status: 'failed') }

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
      before do
        allow(GovukPayApiClient::GetStatus).to receive(:call).and_raise(GovukPayApiClient::Unavailable)

        # This signals that a fee has been paid. Not using fixtures due to the
        # inability to explicitly pass `let` blocks into shared examples outside
        # of `it` declarations.
        fee.update(govpay_payment_id: govpay_payment_id)
      end

      it 'does not update glimr' do
        visit post_pay_fee_url(fee)
        expect(GlimrApiClient::Update).not_to receive(:call)
      end

      it 'notifies the user' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('We couldn’t find your payment details.')
      end
    end

    context 'glimr update fails' do
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
end
