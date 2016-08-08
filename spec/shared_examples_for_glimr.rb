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

RSpec.shared_examples 'request payable case fees' do |code, g_response|
  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      with(body: "jurisdictionId=8&caseNumber=TC%2F2012%2F00001&caseConfirmationCode=ABC123",
           headers: { 'Accept' => 'application/json' }).
      to_return(status: code, body: g_response.to_json)
  end
end


RSpec.shared_examples 'case fee is £20' do
  let(:response_body) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [{ 'feeLiabilityId' => 7,
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => 2000 }]
    }
  }

  before do
    stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
      with(body: /jurisdictionId=8&caseNumber=.+&caseConfirmationCode=ABC123/,
           headers: { 'Accept' => 'application/json' }).
      to_return(status: 200, body: response_body.to_json)
  end
end

RSpec.shared_examples 'report payment taken to glimr' do
  before do
    stub_request(:post, "https://glimr-test.dsd.io/paymenttaken").
      with(body: /govpayReference=rmpaurrjuehgpvtqg997bt50f&paidAmountInPence=2000/,
           headers: { 'Accept' => 'application/json' }).
      to_return(status: 200)
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
