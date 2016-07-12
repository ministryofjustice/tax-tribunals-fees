require 'rails_helper'

RSpec.describe Govpay::Responses::PaymentStatus do
  let(:govpay_response) {
    {
      'state' => {
        'status' => 'dire',
        'message' => 'flee!'
      }
    }
  }

  subject { described_class.new(govpay_response) }

  describe '#status' do
    it 'exposes the status' do
      expect(subject.status).to eq(govpay_response['state']['status'])
    end
  end

  describe '#message' do
    it 'exposes the message' do
      expect(subject.message).to eq(govpay_response['state']['message'])
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_falsey }
  end
end
