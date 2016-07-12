require 'rails_helper'

RSpec.describe Govpay::Responses::PaymentCreated do
  let(:govpay_response) {
    {
      'payment_id' => '12345',
      '_links' => {
        'next_url' => {
          'href' => 'http://test.com'
        }
      }
    }
  }

  subject { described_class.new(govpay_response) }

  describe '#govpay_id' do
    it 'exposes the govpay id' do
      expect(subject.govpay_id).to eq(govpay_response['payment_id'])
    end
  end

  describe '#payment_url' do
    it 'exposes the payment_url' do
      expect(subject.payment_url).
        to eq(govpay_response['_links']['next_url']['href'])
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_falsey }
  end
end
