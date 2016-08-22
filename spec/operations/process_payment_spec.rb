require 'rails_helper'

RSpec.describe ProcessPayment do
  let(:fee_id) { 123 }
  let(:fee) { instance_double(Fee, govpay_payment_id: nil, update: nil, paid?: true, failed?: false, govpay_payment_status: 'error', govpay_payment_message: 'something went wrong') }
  let(:govpay_response) { instance_double(Govpay::Responses::PaymentStatus, status: 'success', message: 'hello') }

  subject(:pp) { described_class.new(fee_id) }

  before do
    allow(Fee).to receive(:find).and_return(fee)
    allow(Glimr).to receive(:fee_paid)
    allow(Govpay).to receive(:get_payment).and_return(govpay_response)
  end

  describe '#error_message' do
    it 'delegates to payment' do
      pp.call
      expect(pp.error_message).to eq('hello')
    end
  end

  describe '#call' do
    it "checks govpay" do
      expect(Govpay).to receive(:get_payment).with(fee)
      pp.call
    end

    it "returns itself" do
      expect(pp.call).to eq(pp)
    end

    it 'sets payment' do
      expect {
        pp.call
      }.to change(pp, :payment).from(nil).to(govpay_response)
    end

    it 'updates the fee status' do
      expect(fee).to receive(:update).with(govpay_payment_status: 'success', govpay_payment_message: 'hello')
      pp.call
    end

    context "when fee is paid" do
      # this is the default for the 'fee' double

      it "updates glimr" do
        expect(Glimr).to receive(:fee_paid).with(fee)
        pp.call
      end

      it "doesn't update glimr when UPDATE_GLIMR is not set" do
        stub_const('ProcessPayment::UPDATE_GLIMR', false)
        expect(Glimr).not_to receive(:fee_paid)
        pp.call
      end

      it "doesn't log" do
        expect(pp).not_to receive(:log_error)
        pp.call
      end
    end

    context "when fee is not paid" do
      let(:fee) { instance_double(Fee, govpay_payment_id: nil, update: nil, paid?: false, failed?: false) }

      it "doesn't update glimr" do
        expect(Glimr).not_to receive(:fee_paid)
        pp.call
      end
    end

    context "when the fee fails" do
      let(:fee) { instance_double(Fee, govpay_payment_id: nil, update: nil, paid?: false, failed?: true, govpay_payment_status: 'error', govpay_payment_message: 'something went wrong') }

      it "logs" do
        expect(pp).to receive(:log_error).with('payment_processor_fee_failure', 'error', 'something went wrong')
        pp.call
      end
    end
  end

  describe '.call' do
    it "instantiates and calls" do
      expect(described_class).to receive(:new).with(fee_id).and_return(pp)
      expect(pp).to receive(:call)
      described_class.call fee_id
    end
  end

  it "finds the fee" do
    expect(Fee).to receive(:find).with(fee_id)
    described_class.new fee_id
  end
end
