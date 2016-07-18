require 'rails_helper'

RSpec.describe FeeLiability do
  subject {
    build(
      :fee_liability,
      description: 'Scott Pilgrim vs The World',
      amount: 2000
    )
  }

  it { should belong_to(:case_request) }
  it { should validate_presence_of(:glimr_id) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:amount) }

  describe '#govpay_description' do
    before do
      allow(subject).to receive(:case_request).and_return(
        instance_double(CaseRequest, case_reference: 'ABC123')
      )
    end

    specify {
      expect(subject.govpay_description).
        to eq('ABC123 - Scott Pilgrim vs The World')
    }
  end

  describe '#amount_in_pounds' do
    specify { expect(subject.amount_in_pounds).to eq(20.00) }
  end

  describe '#status_know?' do
    specify { expect(subject.status_known?).to be_falsey }
  end

  describe '#paid?' do
    specify { expect(subject.paid?).to be_falsey }
  end
end
