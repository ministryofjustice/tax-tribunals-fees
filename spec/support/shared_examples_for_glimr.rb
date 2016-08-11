RSpec.shared_examples 'glimr availability request' do |glimr_response|
  before do
    stub_request(:post, 'https://glimr-test.dsd.io/glimravailable').
      with(headers: { 'Accept' => 'application/json' }).
      to_return(status: 200, body: glimr_response.to_json)
  end
end

RSpec.shared_examples 'network error' do
  before do
    allow(Glimr).to receive(:available?).and_raise(Glimr::Api::Unavailable)
  end
end

RSpec.shared_examples 'service is not available' do
  scenario do
    visit '/'
    expect(page).not_to have_text('Start now')
    expect(page).to have_text('The service is currently unavailable')
  end
end

RSpec.shared_examples 'generic glimr response' do |case_number, confirmation_code, status, glimr_response|
  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      with(body: "jurisdictionId=8&caseNumber=#{CGI.escape(case_number)}&caseConfirmationCode=#{confirmation_code}").
      to_return(status: status, body: glimr_response.to_json)
  end
end

RSpec.shared_examples 'no new fees are due' do |case_number, confirmation_code|
  let(:response_body) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []
    }.to_json
  }

  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      with(body: "jurisdictionId=8&caseNumber=#{CGI.escape(case_number)}&caseConfirmationCode=#{confirmation_code}").
      to_return(status: 200, body: response_body)
  end
end

RSpec.shared_examples 'a case fee of £20 is due' do |case_number, confirmation_code|
  let(:response_body) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [{ 'feeLiabilityId' => 7,
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => 2000 }]
    }.to_json
  }

  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      with(body: "jurisdictionId=8&caseNumber=#{CGI.escape(case_number)}&caseConfirmationCode=#{confirmation_code}").
      to_return(status: 200, body: response_body)
  end
end

RSpec.shared_examples 'no fees then a £20 fee' do |case_number, confirmation_code|
  let(:no_fees) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []
    }.to_json
  }

  let(:twenty_pound_fee) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [{ 'feeLiabilityId' => 7,
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => 2000 }]
    }.to_json
  }

  before do
    stub_request(:post, 'https://glimr-test.dsd.io/requestpayablecasefees').
      with(body: "jurisdictionId=8&caseNumber=#{CGI.escape(case_number)}&caseConfirmationCode=#{confirmation_code}").
      to_return([{ body: no_fees }, { body: twenty_pound_fee }])
  end
end

RSpec.shared_examples 'report payment taken to glimr' do
  let(:paymenttaken_response) {
    {
      feeLiabilityId: 123456789,
      feeTransactionId: 123456789,
      paidAmountInPence: 9999
    }.to_json
  }

  before do
    stub_request(:post, "https://glimr-test.dsd.io/paymenttaken").
      with(body: /govpayReference=rmpaurrjuehgpvtqg997bt50f&paidAmountInPence=2000/,
           headers: { 'Accept' => 'application/json' }).
      to_return(status: 200, body: paymenttaken_response)
  end
end

RSpec.shared_examples 'glimr fee_paid returns a 500' do
  before do
    stub_request(:post, "https://glimr-test.dsd.io/paymenttaken").
      with(body: /govpayReference=rmpaurrjuehgpvtqg997bt50f&paidAmountInPence=2000/,
           headers: { 'Accept' => 'application/json' }).
      to_return(status: 500)
  end
end
