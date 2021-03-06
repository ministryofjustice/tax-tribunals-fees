require 'rails_helper'

RSpec.describe 'Request a brand new case' do
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
  end

  describe 'happy path' do
    let(:make_a_case_request) {
      visit '/'
      click_on 'Start now'
      fill_in 'Case reference', with: case_number
      fill_in 'Confirmation code', with: confirmation_code
      click_on 'Find case'
    }

    describe 'and glimr responds normally' do
      let(:glimr_case) {
        instance_double(
          GlimrApiClient::Case,
          title: 'You vs HM Revenue & Customs',
          fees: [
            OpenStruct.new(
              glimr_id: 7,
              description: 'Lodgement Fee',
              amount: 2000
            )
          ]
        )
      }

      before do
        allow(GlimrApiClient::Case).to receive(:find).and_return(glimr_case)
        make_a_case_request
      end

      it 'show the case reference' do
        expect(page).to have_text("Your case reference is #{case_number}")
      end

      it 'highlight the need' do
        expect(page).to have_text("You need to pay the following fee")
      end

      it 'highlight the urgency' do
        expect(page).to have_text("pay your fee immediately")
      end

      it 'show the fee details' do
        expect(page).to have_text("£20 fee to lodge your appeal")
      end

      describe 'payment methods' do
        it 'select the method' do
          expect(page).to have_text("Select your method of payment")
        end

        it 'by card' do
          expect(page).to have_text("Debit or credit card")
        end

        it 'Help with fees' do
          expect(page).to have_text("Help with fees")
        end
      end
    end

    describe 'and glimr returns an error' do
      before do
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::Unavailable)
      end

      it 'then we do not show the fee' do
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
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::Case::InvalidCaseNumber)
      end

      it 'then tell the user the case cannot be found' do
        fill_in 'Case reference', with: 'some junk'
        fill_in 'Confirmation code', with: 'ABC123'
        click_on 'Find case'
        expect(page).to have_text(/we could not find your case/i)
      end
    end

    describe 'a non-existent case' do
      before do
        expect(GlimrApiClient::Case).to receive(:find).and_raise(GlimrApiClient::Case::InvalidCaseNumber)
      end

      it 'then tell the user the case cannot be found' do
        fill_in 'Case reference', with: 'TC/2016/00001'
        fill_in 'Confirmation code', with: 'ABC123'
        click_on 'Find case'
        expect(page).to have_text(/we could not find your case/i)
      end
    end

    describe 'without a confirmation code' do
      it do
        fill_in 'Case reference', with: 'some junk'
        click_on 'Find case'
        expect(page).to have_text("Confirmation code can't be blank")
      end
    end
  end
end
