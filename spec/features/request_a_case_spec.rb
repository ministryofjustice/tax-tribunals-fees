require 'rails_helper'

RSpec.feature 'Request a case' do
  describe 'happy paths' do
    context 'correct information' do
      let(:glimr_response) {
        {
          'jurisdictionId' => 8,
          'tribunalCaseId' => 60_029,
          'caseTitle' => 'You vs HM Revenue & Customs',
          'feeLiabilities' =>
          [
            {
              'feeLiabilityId' => 7,
              'onlineFeeTypeDescription' => 'Lodgement Fee',
              'payableWithUnclearedInPence' => 2000
            }
          ]
        }
      }

      before do
        stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
          with(body: "jurisdictionId=8&caseNumber=TC%2F2012%2F00001&caseConfirmationCode=ABC123",
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 200, body: glimr_response.to_json)
      end

      scenario do
        visit '/'
        click_on 'Start now'
        expect(page).to have_text('Case Reference')
        expect(page).to have_text('Confirmation Code')
        fill_in 'Case Reference', with: 'TC/2012/00001'
        fill_in 'Confirmation Code', with: 'ABC123'
        click_on 'Find Case'
        expect(page).to have_text('You vs HM Revenue & Customs')
        expect(page).to have_text('£20.00')
        expect(page).to have_text('Lodgement Fee')
      end
    end # 'correct information'

    context 'with a bad case reference' do
      scenario do
        visit '/'
        click_on 'Start now'
        fill_in 'Case Reference', with: 'some junk'
        fill_in 'Confirmation Code', with: 'ABC123'
        click_on 'Find Case'
        expect(page).to have_text('Sorry - we could not find your case.')
        expect(page).to have_text('Case reference is invalid')
      end
    end # 'with a bad case reference'

    context 'without a confirmation code' do
      scenario do
        visit '/'
        click_on 'Start now'
        fill_in 'Case Reference', with: 'some junk'
        click_on 'Find Case'
        expect(page).to have_text('Sorry - we could not find your case.')
        expect(page).to have_text("Confirmation code can't be blank")
      end
    end # 'without a confirmation code'

    context 'when glimr returns an error' do
      let(:glimr_response) {
        {
          'glimrerrorcode' => 418,
          'message' => 'I’m a teapot'
        }
      }

      before do
        stub_request(:post, "https://glimr-test.dsd.io/requestpayablecasefees").
          with(body: "jurisdictionId=8&caseNumber=TC%2F2012%2F00001&caseConfirmationCode=ABC123",
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 418, body: glimr_response.to_json)
      end

      scenario do
        visit '/'
        click_on 'Start now'
        fill_in 'Case Reference', with: 'TC/2012/00001'
        fill_in 'Confirmation Code', with: 'ABC123'
        click_on 'Find Case'
        expect(page).to have_text('Sorry - we could not find your case.')
      end
    end # 'when glimr returns an error'
  end # 'happy paths'
end
