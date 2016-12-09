require 'rails_helper'

RSpec.feature 'Help with fees' do
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
      choose 'Help with fees'
      click_on 'Continue'
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

      scenario 'shows the correct page' do
        expect(page).to have_text("Pay via help with fees")
      end

      scenario 'has the correct case' do
        expect(page).to have_text(case_number)
        expect(page).to have_text('You vs HM Revenue & Customs')
      end

      scenario 'has the correct amount' do
        expect(page).to have_text('Total amount £20')
      end

      scenario 'has the correct type' do
        expect(page).to have_text('Lodgement Fee')
      end

      describe 'submit' do
        scenario 'send data to glimr and do not require a data response' do
          expect(GlimrApiClient::HwfRequested).to receive(:call).with(
            { feeLiabilityId: 7,
              hwfRequestReference: 'ABC123',
              amountToPayInPence: 2000 }
          )
          fill_in 'Help with fees reference number', with: 'ABC123'
          click_on 'Continue'
          expect(page).to have_text('Payment successful')
          expect(page).to have_text('Fee paid via help with fees reference ABC123' )
        end
      end
    end
  end
end
