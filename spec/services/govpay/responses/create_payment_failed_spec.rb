require 'rails_helper'

RSpec.describe Govpay::Responses::CreatePaymentFailed do
  let(:govpay_response) {
    {
      'code' => 'code',
      'message' => 'something happened',
      'description' => 'something bad happened'
    }
  }

  subject { described_class.new(govpay_response) }

  describe '#error_code' do
    it 'exposes the error class' do
      expect(subject.error_code).to eq(govpay_response['code'])
    end
  end

  describe '#error_message' do
    it 'exposes the error message' do
      expect(subject.error_message).to eq(govpay_response['message'])
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_truthy }
  end
end
