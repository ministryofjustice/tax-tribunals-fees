require 'rails_helper'
require 'support/shared_examples_for_govpay'
require 'support/shared_examples_for_glimr'
require 'support/create_a_fee'

RSpec.feature 'Pay for a case' do
  describe '#post_pay' do
    case_number = 'TC/2012/00001'
    confirmation_code = 'ABC123'

    include_examples 'a case fee of £20 is due', case_number, confirmation_code
    include_examples 'govpay payment response', fee.govpay_payment_id
    # This is already tested by the Excon stubs, which are excercised by many
    # of the specs in this block. However, for completeness, I have included
    # this spec, which mirrors the negative version(s) used in the failure
    # spec, below.
    it_should_behave_like 'glimr update gets called'

    before do
      fee.update(govpay_payment_id: 'rmpaurrjuehgpvtqg997bt50f')
    end

    context 'a successful payment' do
      include_examples 'report payment taken to glimr',
        /govpayReference=rmpaurrjuehgpvtqg997bt50f&paidAmountInPence=2000/

      before do
        visit post_pay_fee_url(fee)
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
        fee.update(govpay_payment_id: 'rmpaurrjuehgpvtqg997bt50f')
      end

      it 'does not try to update glimr' do
        expect(GlimrApiClient::Update).not_to receive(:call)
        visit post_pay_fee_url(fee)
      end

      it 'alerts the user to the failure and reason' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('we couldn’t take your payment')
      end
    end

    context 'govpay fails' do
      # This signals that a fee has been paid. Not using fixtures due to the
      # inability to explicitly pass `let` blocks into shared examples outside
      # of `it` declarations.
      before do
        fee.update(govpay_payment_id: 'rmpaurrjuehgpvtqg997bt50f')
      end

      include_examples 'govpay post_pay returns a 500', fee.govpay_payment_id
      it_should_behave_like 'glimr update does not get called'

      it 'alerts the user to the failure and reason' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('We couldn’t find your payment details.')
      end
    end

    context 'govpay payment status times out' do
      include_examples 'govpay payment status times out', fee.govpay_payment_id
      it_should_behave_like 'glimr update does not get called'

      it 'alerts the user to the failure' do
        visit post_pay_fee_url(fee)
        expect(page).to have_text('We couldn’t find your payment details.')
      end
    end

    context 'glimr update fails' do
      include_examples 'glimr fee_paid returns a 500'

      it 'alerts the user to the failure and reason' do
        visit post_pay_fee_url(fee)
        expect(page).
          to have_text('error updating your case with your payment details')
      end
    end
  end

  # A successful call to `#pay` is tested with a request spec as it involves a
  # redirect to the Gov UK Payment gateway.
  describe '#pay' do
    context 'the GovPay API returns a 404' do
      include_examples 'govpay returns a 404', fee
      it_should_behave_like 'glimr update does not get called'

      it 'alerts the user the service is unavailable' do
        visit pay_fee_url(fee)
        expect(page).to have_text('The service is currently unavailable')
      end
    end

    context 'govpay times out' do
      include_examples 'govpay create payment times out', fee
      it_should_behave_like 'glimr update does not get called'

      it 'alerts the user the service is unavailable' do
        visit pay_fee_url(fee)
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end
end
