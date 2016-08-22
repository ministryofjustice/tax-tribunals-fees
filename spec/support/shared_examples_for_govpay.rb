module GovpayExample
  module Mocks
    def glimr_api_call
      class_double(
        Excon,
        'glimr availability check',
        post: instance_double(
          Excon::Response,
          status: 200,
          body: { glimrAvailable: 'yes' }.to_json
        )
      )
    end

    def a_create_payment_success(initial_payment_response)
      class_double(
        Excon,
        'glimr availability check',
        post: instance_double(
          Excon::Response,
          status: 200,
          body: initial_payment_response
        )
      )
    end

    def a_create_payment_timeout
      class_double(Excon, 'create payment timeout').tap { |ex|
        expect(ex).to receive(:post).and_raise(Excon::Errors::Timeout)
      }
    end

    def a_payment_status_timeout
      class_double(Excon, 'create payment timeout').tap { |ex|
        expect(ex).to receive(:get).and_raise(Excon::Errors::Timeout)
      }
    end
  end

  module Responses
    def initial_payment_response(payment_id = 'rmpaurrjuehgpvtqg997bt50f')
      {
        'payment_id' => payment_id,
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
    end

    def post_pay_response
      {
        'payment_id' => 'oio28jhr7mj6rqc9g12pff2i44',
        'payment_provider' => 'sandbox', 'amount' => 2000,
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
    end
  end
end

RSpec.shared_examples 'govpay payment response' do
  let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }
  include GovpayExample::Responses

  let(:fee) { create(:fee) }

  let(:request_body) {
    {
      return_url: CGI.unescape(post_pay_fee_url(fee)),
      description: fee.govpay_description,
      reference: fee.govpay_reference,
      amount: fee.amount
    }.to_json
  }

  before do
    Excon.stub(
      {
        method: :post,
        host: 'govpay-test.dsd.io',
        body: request_body,
        path: '/payments'
      },
      status: 201, body: initial_payment_response(govpay_payment_id)
    )

    Excon.stub(
      {
        method: :get,
        host: 'govpay-test.dsd.io',
        path: "/payments/#{govpay_payment_id}"
      },
      status: 200, body: post_pay_response
    )
  end
end

RSpec.shared_examples 'govpay returns a 404' do
  let!(:fee) { create(:fee) }

  let(:request_body) {
    {
      return_url: CGI.unescape(post_pay_fee_url(fee)),
      description: fee.govpay_description,
      reference: fee.govpay_reference,
      amount: fee.amount
    }.to_json
  }

  before do
    Excon.stub(
      {
        method: :post,
        host: 'govpay-test.dsd.io',
        body: request_body,
        path: '/payments'
      },
      status: 404
    )
  end
end

RSpec.shared_examples 'govpay post_pay returns a 500' do
  let(:govpay_payment_id) { 'rmpaurrjuehgpvtqg997bt50f' }

  before do
    Excon.stub(
      {
        method: :get,
        host: 'govpay-test.dsd.io',
        path: "/payments/#{govpay_payment_id}"
      },
      status: 500, body: '{"message":"Govpay is not working"}'
    )
  end
end

RSpec.shared_examples 'govpay payment status times out' do
  include GovpayExample::Responses
  include GovpayExample::Mocks

  before do
    allow(Excon).to receive(:new).
      with(Rails.configuration.glimr_api_url, anything).
      and_return(glimr_api_call)

    expect(Excon).to receive(:new).
      with(Rails.configuration.govpay_api_url, anything).
      and_return(
        a_create_payment_success(initial_payment_response),
        a_payment_status_timeout
      )
  end
end

RSpec.shared_examples 'govpay create payment times out' do
  include GovpayExample::Responses
  include GovpayExample::Mocks

  before do
    allow(Excon).to receive(:new).
      with(Rails.configuration.glimr_api_url, anything).
      and_return(glimr_api_call)

    expect(Excon).to receive(:new).
      with(Rails.configuration.govpay_api_url, anything).
      and_return(a_create_payment_timeout)
  end
end
