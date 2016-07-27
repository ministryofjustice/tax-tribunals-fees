RSpec.shared_examples 'govpay payment response' do
  let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }
  let(:initial_payment_response) {
    {
      'payment_id' => govpay_payment_id,
      'payment_provider' => 'sandbox',
      'amount' => 2000,
      'state' => {
        'status' => 'created',
        'finished' => false
      },
      'description' => 'TC/2016/00001 - Lodgement Fee',
      'return_url' => 'https://replace-me-with-localhost.com/liabilities/960eb61a-a592-4e79-a5f8-c35cde24352a/post_pay',
      'reference' => '7G20160718180649',
      'created_date' => '2016-07-18T17:06:53.172Z',
      '_links' => {
        'self' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/rmpaurrjuehgpvtqg997bt50fm',
          'method' => 'GET'
        },
        'next_url' => {
          'href' => 'https://www-integration-2.pymnt.uk/secure/94b35000-37f2-44e6-a2f5-c0193ca1e98a',
          'method' => 'GET'
        },
        'next_url_post' => {
          'type' => 'application/x-www-form-urlencoded',
          'params' => {
            'chargeTokenId' => '94b35000-37f2-44e6-a2f5-c0193ca1e98a'
          },
          'href' => 'https://www-integration-2.pymnt.uk/secure',
          'method' => 'POST'
        },
        'events' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/rmpaurrjuehgpvtqg997bt50fm/events',
          'method' => 'GET'
        },
        'cancel' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/rmpaurrjuehgpvtqg997bt50fm/cancel',
          'method' => 'POST'
        }
      }
    }.to_json
  }

  let(:post_pay_response) {
    {
      'payment_id' => 'oio28jhr7mj6rqc9g12pff2i44',
      'payment_provider' => 'sandbox',
      'amount' => 2000,
      'state' => {
        'status' => 'success',
        'finished' => true
      },
      'description' => 'TC/2016/00001 - Lodgement Fee',
      'return_url' => 'https://replace-me-with-localhost.com/liabilities/7f475fde-b509-4612-bffb-e2dac0066f4c/post_pay',
      'reference' => '7G20160725115358',
      'created_date' => '2016-07-25T10:54:00.294Z',
      '_links' => {
        'self' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/oio28jhr7mj6rqc9g12pff2i44',
          'method' => 'GET'
        },
        'next_url' => nil,
        'next_url_post' => nil,
        'events' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/oio28jhr7mj6rqc9g12pff2i44/events',
          'method' => 'GET'
        },
        'cancel' => nil
      }
    }.to_json
  }

  let!(:liability) { create(:fee_liability) }

  let(:request_body) {
    {
      return_url: CGI.unescape(post_pay_liability_url(liability)),
      description: liability.govpay_description,
      reference: liability.govpay_reference,
      amount: liability.amount
    }.to_json
  }

  before do
    stub_request(:post, "https://govpay-test.dsd.io/payments").
      with(
        body: request_body,
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Bearer deadbeef',
          'Content-Type' => 'application/json'
        }
      ).to_return(status: 200, body: initial_payment_response)

    stub_request(:get, "https://govpay-test.dsd.io/payments/#{govpay_payment_id}").
      with(
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Bearer deadbeef',
          'Content-Type' => 'application/json'
        }
      ).to_return(status: 200, body: post_pay_response)
  end
end

RSpec.shared_examples 'govpay returns a 404' do
  let!(:liability) { create(:fee_liability) }

  let(:request_body) {
    {
      return_url: CGI.unescape(post_pay_liability_url(liability)),
      description: liability.govpay_description,
      reference: liability.govpay_reference,
      amount: liability.amount
    }.to_json
  }

  before do
    stub_request(:post, "https://govpay-test.dsd.io/payments").
      with(
        body: request_body,
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Bearer deadbeef',
          'Content-Type' => 'application/json'
        }
      ).to_return(status: 404)
  end
end

RSpec.shared_examples 'govpay post_pay returns a 500' do
  let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }
  before do
    stub_request(:get, "https://govpay-test.dsd.io/payments/#{govpay_payment_id}").
      with(
        headers: {
          'Accept' => 'application/json',
          'Authorization' => 'Bearer deadbeef',
          'Content-Type' => 'application/json'
        }
      ).to_return(status: 500, body: '{"message":"Govpay is not working"}')
  end
end
