require 'rails_helper'

RSpec.describe Govpay::Requests::CreatePayment do
  let(:fee_liability) {
    instance_double(
      'FeeLiability',
      glimr_id: 'ABC123',
      govpay_reference: 1234,
      govpay_payment_id: 1234,
      amount: 20,
      govpay_description: 'description',
      to_param: 1234
    )
  }

  subject {
    described_class.new(fee_liability)
  }

  describe '#call' do
    context 'successful' do
      before do
        stub_request(
          :post, "https://govpay-test.dsd.io/payments"
        ).with(
          body: "{\"return_url\":\"http://localhost:3000/liabilities/1234/post_pay\",\"description\":\"description\",\"reference\":1234,\"amount\":20}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer deadbeef',
            'Content-Type' => 'application/json'
          }
        ).to_return(status: 200)
      end

      it 'creates a new Responses::CaseFees instance' do
        expect(subject.call).
          to be_an_instance_of(Govpay::Responses::PaymentCreated)
      end
    end

    context 'unsuccessful' do
      before do
        stub_request(
          :post, "https://govpay-test.dsd.io/payments"
        ).with(
          body: "{\"return_url\":\"http://localhost:3000/liabilities/1234/post_pay\",\"description\":\"description\",\"reference\":1234,\"amount\":20}",
          headers: {
            'Accept' => 'application/json',
            'Authorization' => 'Bearer deadbeef',
            'Content-Type' => 'application/json'
          }
        ).to_return(status: 404)
      end

      it 'creates a new Responses::CaseNotFound instance' do
        expect(subject.call).
          to be_an_instance_of(Govpay::Responses::CreatePaymentFailed)
      end
    end
  end
end
