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

RSpec.shared_examples 'payment taken' do
  before do
  stub_request(:post, "https://glimr-test.dsd.io/paymenttaken").
    with(:body => %r[govpayReference=rmpaurrjuehgpvtqg997bt50f&paidAmountInPence=2000],
         :headers => {'Accept'=>'application/json'}).
    to_return(status: 200)
  end
end
