require 'rails_helper'

RSpec.describe 'Pay for a case' do
  include_examples 'govpay payment response'
  let!(:liability) { create(:fee_liability) }

  before do
    stub_request(:post, "https://govpay-test.dsd.io/payments").
      # I don’t like this, but it will do for the moment.
      with(body: /liabilities\/.+\/post_pay.*TC\/2012\/00001.*2000/,
           headers: {'Accept' => 'application/json', 'Authorization' => 'Bearer deadbeef', 'Content-Type' => 'application/json'}).
      to_return(status: 200, body: initial_payment_response)
  end

  it do
    get "/liabilities/#{liability.id}/pay"
  end
end
