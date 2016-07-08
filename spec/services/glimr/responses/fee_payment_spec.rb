require 'rails_helper'

RSpec.describe Glimr::Responses::FeePayment do
  let(:glimr_response) {
    {
      'feeTransactionId' => 'some id'
    }
  }

  subject { described_class.new(glimr_response) }

  describe '#fee_transaction_id' do
    it 'exposes the fee transaction id' do
      expect(subject.fee_transaction_id).
        to eq(glimr_response['feeTransactionId'])
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_falsey }
  end
end
