require 'rails_helper'

RSpec.describe Glimr::Responses::CaseFees do
  let(:glimr_response) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [
        {
          'feeLiabilityId' => 7,
          'onlineFeeTypeDescription' => 'Lodgement Fee',
          'payableWithUnclearedInPence' => 2000
        }
      ]
    }
  }

  subject { described_class.new(glimr_response) }

  it '#jurisdiction' do
    expect(subject.jurisdiction).to eq(8)
  end

  it '#title' do
    expect(subject.title).to eq('You vs HM Revenue & Customs')
  end

  describe '#fee_liabilities' do
    let(:fee_liabilities) { subject.fee_liabilities.first }
    it { expect(fee_liabilities.glimr_id).to eq(7) }
    it { expect(fee_liabilities.description).to eq('Lodgement Fee') }
    it { expect(fee_liabilities.amount).to eq(2000) }
  end

  describe '#error?' do
    it { expect(subject.error?).to be_falsey }
  end
end
