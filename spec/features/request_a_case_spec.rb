require 'rails_helper'

RSpec.feature 'Request a brand new case' do
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  describe 'happy path' do
    let(:make_a_case_request) {
      visit '/'
      click_on 'Start now'
      fill_in 'Case reference', with: case_number
      fill_in 'Confirmation code', with: confirmation_code
      click_on 'Find case'
    }

    describe 'and glimr responds normally' do
      let(:glimr_case) { double(
        title: 'You vs HM Revenue & Customs',
        fees: [
          double(
            glimr_id: 7,
            description: 'Lodgement Fee',
            amount: 2000
          )
        ]
      ) }

      before do
        allow(GlimrApiClient::Case).to receive(:find).and_return(glimr_case)
      end

      scenario 'then we show the fee' do
        make_a_case_request
        expect(page).to have_text('£20.00')
      end

      scenario 'then we show the type of fee' do
        make_a_case_request
        expect(page).to have_text('Lodgement Fee')
      end
    end

    describe 'and glimr returns an error' do
      before do
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::Unavailable)
      end

      scenario 'then we do not show the fee' do
        make_a_case_request
        # TODO: This is not ideal.  It should alert the user to the failure.
        expect(page).to have_text('service is currently unavailable')
      end
    end
  end

  context 'user sends bad data' do
    before do
      visit '/'
      click_on 'Start now'
    end

    describe 'a bad case reference' do
      before do
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::CaseNotFound)
      end

      scenario 'then tell the user the case cannot be found' do
        fill_in 'Case reference', with: 'some junk'
        fill_in 'Confirmation code', with: 'ABC123'
        click_on 'Find case'
        expect(page).to have_text(/we could not find your case/i)
      end
    end

    describe 'a non-existent case' do
      before do
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::CaseNotFound)
      end

      scenario 'then tell the user the case cannot be found' do
        fill_in 'Case reference', with: 'TC/2016/00001'
        fill_in 'Confirmation code', with: 'ABC123'
        click_on 'Find case'
        expect(page).to have_text(/we could not find your case/i)
      end
    end

    describe 'without a confirmation code' do
      scenario do
        fill_in 'Case reference', with: 'some junk'
        click_on 'Find case'
        expect(page).to have_text("Confirmation code can't be blank")
      end
    end
  end
end
