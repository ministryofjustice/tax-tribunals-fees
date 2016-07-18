require 'rails_helper'
require 'shared_examples_for_glimr'
require 'shared_examples_for_govpay'

RSpec.feature 'Pay for a case' do
  include_examples 'glimr availability request', glimrAvailable: 'yes'

  before do
    stub_request(:post, "https://govpay-test.dsd.io/payments").
      # I don’t like this, but it will do for the moment.
      with(body: /liabilities\/.+\/post_pay.*TC\/2012\/00001.*2000/,
           headers: {'Accept' => 'application/json', 'Authorization' => 'Bearer deadbeef', 'Content-Type' => 'application/json'}).
      to_return(status: 200, body: initial_payment_response)
  end

  describe 'happy paths' do
    context 'correct information' do
      include_examples 'request payable case fees', 200,
        'jurisdictionId' => 8,
        'tribunalCaseId' => 60_029,
        'caseTitle' => 'You vs HM Revenue & Customs',
        'feeLiabilities' =>
           [{ 'feeLiabilityId' => 7,
              'onlineFeeTypeDescription' => 'Lodgement Fee',
              'payableWithUnclearedInPence' => 2000 }]

      scenario do
        visit '/'
        click_on 'Start now'
        fill_in 'Case Reference', with: 'TC/2012/00001'
        fill_in 'Confirmation Code', with: 'ABC123'
        click_on 'Find Case'
        expect(page).to have_text('£20.00')
        expect(page).to have_text('Lodgement Fee')
        click_on 'Pay now'
      end
    end # 'correct information'
  end # 'happy paths'
end
