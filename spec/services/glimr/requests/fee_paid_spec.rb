require 'rails_helper'

RSpec.describe Glimr::Requests::FeePaid do
  let(:fee_liability) {
    instance_double(
      'FeeLiability',
      glimr_id: 'ABC123',
      govpay_reference: 12_345,
      govpay_payment_id: 12_345,
      amount: 20
    )
  }

  subject {
    described_class.new(fee_liability)
  }

  describe '#call' do
    context 'successful' do
      before do
        stub_request(:post, 'https://glimr-test.dsd.io/paymenttaken').
          with(body: 'feeLiabilityId=ABC123&paymentReference=12345&govpayReference=12345&paidAmountInPence=20',
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 200)
      end

      it 'creates a new Responses::CaseFees instance' do
        expect(subject.call).to be_an_instance_of(Glimr::Responses::FeePayment)
      end
    end

    context 'unsuccessful' do
      before do
        stub_request(:post, 'https://glimr-test.dsd.io/paymenttaken').
          with(body: 'feeLiabilityId=ABC123&paymentReference=12345&govpayReference=12345&paidAmountInPence=20',
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 404)
      end

      it 'creates a new Responses::CaseNotFound instance' do
        expect(subject.call).to be_an_instance_of(Glimr::Responses::CaseNotFound)
      end
    end
  end
end
