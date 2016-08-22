require 'rails_helper'

RSpec.describe Govpay::Requests::GetPaymentStatus do
  let(:liability) {
    instance_double(
      'Liability',
      glimr_id: 'ABC123',
      govpay_reference: 1234,
      govpay_payment_id: 1234,
      amount: 20,
      govpay_description: 'description'
    )
  }

  subject {
    described_class.new(liability)
  }

  describe '#call' do
    context 'successful' do
      before do
        Excon.stub(
          {
            method: :get,
            host: 'govpay-test.dsd.io',
            path: '/payments/1234'
          },
          status: 200, body: {}.to_json
        )
      end

      it 'creates a new Responses::CaseFees instance' do
        expect(subject.call).
          to be_an_instance_of(Govpay::Responses::PaymentStatus)
      end
    end

    context 'unsuccessful' do
      before do
        Excon.stub(
          {
            method: :get,
            host: 'govpay-test.dsd.io',
            path: '/payments/1234'
          },
          status: 404
        )
      end
    end
  end
end
