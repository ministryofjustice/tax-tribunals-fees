require 'rails_helper'

RSpec.describe Fee do
  let(:params) { {
    case_reference: 'caseref',
    description: 'Someone vs. HMRC',
    glimr_id: '2345',
    amount: 1234
  } }

  subject(:fee) { described_class.new(params) }

  describe '#amount_in_pounds' do
    it "divides by 100" do
      expect(fee.amount_in_pounds).to eq(12.34)
    end
  end

  describe 'confirmation_code' do
    let(:params) { super().merge(confirmation_code: 'CONFIRM') }

    it "stores digest on save" do
      expect(BCrypt::Password).to receive(:create).twice().with('CONFIRM')
      fee.save
    end
  end
end
