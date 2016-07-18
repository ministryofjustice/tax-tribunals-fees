RSpec.shared_examples 'govpay payment response' do
  let(:initial_payment_response) {
    { 'payment_id' => 'rmpaurrjuehgpvtqg997bt50fm',
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
      '_links'=> {
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
          'params'=> {
            'chargeTokenId' => '94b35000-37f2-44e6-a2f5-c0193ca1e98a'
          },
          'href' => 'https://www-integration-2.pymnt.uk/secure',
          'method' => 'POST'
        },
        'events' => {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/rmpaurrjuehgpvtqg997bt50fm/events',
          'method' => 'GET'
        },
        'cancel'=> {
          'href' => 'https://publicapi.pymnt.uk/v1/payments/rmpaurrjuehgpvtqg997bt50fm/cancel',
          'method' => 'POST'
        }
      }
  }.to_json
  }
end
