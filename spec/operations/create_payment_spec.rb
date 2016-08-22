require 'rails_helper'

RSpec.describe CreatePayment do
  let(:fee_id) { 123 }
  let(:fee) { instance_double(Fee, update: nil) }
  let(:govpay_response) { instance_double(Govpay::Responses::PaymentCreated, govpay_id: '23456') }

  subject(:cp) { described_class.new(fee_id) }

  before do
    allow(Fee).to receive(:find).and_return(fee)
  end

  it 'finds the fee' do
    expect(Fee).to receive(:find).with(fee_id)
    described_class.new fee_id
  end

  describe '#payment' do
    before do
      allow(Govpay).to receive(:create_payment).with(fee).and_return(govpay_response)
    end

    it 'creates govpay payment' do
      expect(Govpay).to receive(:create_payment).with(fee)
      cp.payment
    end

    it "updates the fee" do
      expect(fee).to receive(:update).with(govpay_payment_id: '23456')
      cp.payment
    end
  end
end
