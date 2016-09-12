require 'rails_helper'

RSpec.describe Fee do
  let(:params) {
    {
      case_reference: 'caseref',
      description: 'Someone vs. HMRC',
      glimr_id: '2345',
      amount: 1234,
      confirmation_code: 'ABC123'
    }
  }

  subject(:fee) { described_class.new(params) }

  it "sets govpay_reference" do
    allow(Time).to receive(:zone).and_return(ActiveSupport::TimeZone["Samoa"])
    travel_to(Time.zone.parse("2016-03-17 16:23:00")) do
      expect { fee.save }.to change(fee, :govpay_reference).from(nil).to("2345G20160317162300")
    end
  end

  it "sets govpay_description" do
    expect(fee.govpay_description).to eq('caseref - Someone vs. HMRC')
  end

  context 'when payment succeeded' do
    let(:params) { super().merge(govpay_payment_status: 'success') }

    it "has succeeded" do
      expect(fee.paid?).to be_truthy
    end

    it "hasn't failed" do
      expect(fee.failed?).to be_falsey
    end

    it "has known status" do
      expect(fee.status_known?).to eq(true)
    end
  end

  context 'when payment failed' do
    let(:params) { super().merge(govpay_payment_status: 'some other value') }

    it "hasn't succeeded" do
      expect(fee.paid?).to be_falsey
    end

    it "has failed" do
      expect(fee.failed?).to be_truthy
    end

    it "has known status" do
      expect(fee.status_known?).to eq(true)
    end
  end

  context 'when status is unknown' do
    let(:params) { super().merge(govpay_payment_status: nil) }

    it "hasn't failed" do
      expect(fee.failed?).to be_falsey
    end

    it "hasn't succeeded" do
      expect(fee.paid?).to be_falsey
    end

    it "has unknown status" do
      expect(fee.status_known?).to eq(false)
    end
  end

  describe '#amount_in_pounds' do
    it "divides by 100" do
      expect(fee.amount_in_pounds).to eq(12.34)
    end
  end

  describe 'confirmation_code' do
    before do
      fee.save
    end

    it "stores digest on save" do
      expect(fee.confirmation_code_digest).not_to be_nil
    end

    it "encrypts the confirmation code" do
      expect(BCrypt::Password.new(fee.confirmation_code_digest)).to eq('ABC123')
    end
  end
end
