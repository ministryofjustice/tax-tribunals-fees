require 'rails_helper'

RSpec.describe 'Pay for a case', type: :request do
  # `#post_pay` and failed calls to `#pay` are tested with feature specs as
  # they do not involve redirects to the govuk payment gateway and feature
  # specs are otherwise somewhat more declarative and easier to deal with.
  let(:fee) { create(:fee) }

  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  let(:next_url) { 'https://www-integration-2.pymnt.uk/secure/94b35000-37f2-44e6-a2f5-c0193ca1e98a' }

  let(:govpay_response) {
    OpenStruct.new(next_url: next_url)
  }

  before do
    allow(GovukPayApiClient::CreatePayment).to receive(:call).and_return(govpay_response)
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
  end

  describe '#pay' do
    context 'succeeds' do
      it 'redirects to the govpay payment URL' do
        get "/fees/#{fee.id}/pay"
        expect(response).to redirect_to(next_url)
      end
    end

    context 'when govuk pay fails' do
      before do
        allow(GovukPayApiClient::CreatePayment).to receive(:call).and_raise(GovukPayApiClient::Unavailable)
      end

      it 'redirects to the application root URL' do
        get "/fees/#{fee.id}/pay"
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
