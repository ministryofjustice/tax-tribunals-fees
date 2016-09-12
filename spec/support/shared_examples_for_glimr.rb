RSpec.shared_examples 'glimr availability request' do |glimr_response|
  before do
    Excon.stub(
      { host: 'glimr-test.dsd.io', path: '/glimravailable' },
      status: 200, body: glimr_response.to_json
    )
  end
end

RSpec.shared_examples 'glimr availability request returns a 500' do
  before do
    Excon.stub(
      { host: 'glimr-test.dsd.io', path: '/glimravailable' },
      status: 500
    )
  end
end

RSpec.shared_examples 'service is not available' do
  scenario do
    visit '/'
    expect(page).not_to have_text('Start now')
    expect(page).to have_text('The service is currently unavailable')
  end
end

RSpec.shared_examples 'generic glimr response' do |case_number, _confirmation_code, status, glimr_response|
  before do
    Excon.stub(
      {
        host: 'glimr-test.dsd.io',
        body: /caseNumber=#{CGI.escape(case_number)}/,
        path: '/requestpayablecasefees'
      },
      status: status, body: glimr_response.to_json
    )
  end
end

RSpec.shared_examples 'case not found' do
  before do
    Excon.stub(
      {
        host: 'glimr-test.dsd.io',
        path: '/requestpayablecasefees'
      },
      status: 404
    )
  end
end

RSpec.shared_examples 'no new fees are due' do |case_number, _confirmation_code|
  let(:response_body) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []
    }
  }

  before do
    Excon.stub(
      {
        host: 'glimr-test.dsd.io',
        body: /caseNumber=#{CGI.escape(case_number)}/,
        path: '/requestpayablecasefees'
      },
      status: 200, body: response_body.to_json
    )
  end
end

RSpec.shared_examples 'a case fee of £20 is due' do |case_number, _confirmation_code|
  let(:response_body) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' =>
      [{ 'feeLiabilityId' => '7',
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => '2000' }]
    }.to_json
  }

  before do
    Excon.stub(
      {
        method: :post,
        host: 'glimr-test.dsd.io',
        body: /caseNumber=#{CGI.escape(case_number)}&jurisdictionId=8/,
        path: '/requestpayablecasefees'
      },
      status: 200, body: response_body
    )
  end
end

RSpec.shared_examples 'no fees then a £20 fee' do |case_number, _confirmation_code|
  let(:no_fees) {
    {
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []
    }
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
    }
  }

  before do
    Excon.stub(
      {
        method: :post,
        host: 'glimr-test.dsd.io',
        body: /caseNumber=#{CGI.escape(case_number)}/,
        path: '/requestpayablecasefees'
      },
      status: 200, body: no_fees.to_json
    )

    Excon.stub(
      {
        method: :post,
        host: 'glimr-test.dsd.io',
        body: /caseNumber=#{CGI.escape(case_number)}/,
        path: '/requestpayablecasefees'
      },
      status: 200, body: twenty_pound_fee.to_json
    )
  end
end

RSpec.shared_examples 'report payment taken to glimr' do |req_body|
  let(:paymenttaken_response) {
    {
      feeLiabilityId: 1234,
      feeTransactionId: 1234,
      paidAmountInPence: 9999
    }
  }

  before do
    Excon.stub(
      {
        method: :post,
        host: 'glimr-test.dsd.io',
        body: req_body,
        path: '/paymenttaken'
      },
      status: 200, body: paymenttaken_response.to_json
    )
  end
end

RSpec.shared_examples 'glimr fee_paid returns a 500' do
  before do
    Excon.stub(
      {
        method: :post,
        host: 'glimr-test.dsd.io',
        path: '/paymenttaken'
      },
      status: 500
    )
  end
end

RSpec.shared_examples 'glimr times out' do
  before do
    Excon.stub(
       host: 'glimr-test.dsd.io'
    ) {
      raise Excon::Errors::Timeout
    }
  end
end

RSpec.shared_examples 'glimr has a socket error' do
  before do
    Excon.stub(
       host: 'glimr-test.dsd.io'
    ) {
      raise Excon::Errors::SocketError
    }
  end
end
