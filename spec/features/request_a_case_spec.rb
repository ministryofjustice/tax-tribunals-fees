require 'rails_helper'
require 'shared_examples_for_glimr'

RSpec.feature 'Request a brand new case' do
  include_examples 'glimr availability request', glimrAvailable: 'yes'

  describe 'happy path' do
    let(:make_a_case_request) {
      visit '/'
      click_on 'Start now'
      fill_in 'Case Reference', with: 'TC/2012/00001'
      fill_in 'Confirmation Code', with: 'ABC123'
      click_on 'Find Case'
    }

    describe 'and glimr responds normally' do
      include_examples 'request payable case fees', 200,
        'jurisdictionId' => 8,
        'tribunalCaseId' => 60_029,
        'caseTitle' => 'You vs HM Revenue & Customs',
        'feeLiabilities' =>
      [{ 'feeLiabilityId' => 7,
         'onlineFeeTypeDescription' => 'Lodgement Fee',
         'payableWithUnclearedInPence' => 2000 }]

      scenario 'then we show the fee' do
        make_a_case_request
        expect(page).to have_text('You vs HM Revenue & Customs')
        expect(page).to have_text('£20.00')
        expect(page).to have_text('Lodgement Fee')
      end
    end

    describe 'and glimr returns an error' do
      include_examples 'request payable case fees', 418,
        'glimrerrorcode' => 418,
        'message' => 'I’m a teapot'

      scenario 'then we do not show the fee' do
        make_a_case_request
        # TODO: This is not ideal.  It should alert the user to the failure.
        expect(page).to have_text('Sorry - we could not find your case.')
      end
    end

    describe 'and glimr times out' do
      before do
        stub_request(:post, 'https://glimr-test.dsd.io/glimravailable').to_timeout
      end

      scenario 'we alert the user' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end

  describe 'with a bad case reference' do
    scenario do
      visit '/'
      click_on 'Start now'
      fill_in 'Case Reference', with: 'some junk'
      fill_in 'Confirmation Code', with: 'ABC123'
      click_on 'Find Case'
      expect(page).to have_text('Sorry - we could not find your case.')
      expect(page).to have_text('Case reference is invalid')
    end
  end

  describe 'without a confirmation code' do
    scenario do
      visit '/'
      click_on 'Start now'
      fill_in 'Case Reference', with: 'some junk'
      click_on 'Find Case'
      expect(page).to have_text('Sorry - we could not find your case.')
      expect(page).to have_text("Confirmation code can't be blank")
    end
  end
end
