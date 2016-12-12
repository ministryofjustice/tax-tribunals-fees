require 'rails_helper'

RSpec.feature 'Pay by account' do
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
      choose 'Authorised account'
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
        expect(page).to have_text("Pay via authorised account")
      end

      scenario 'has the correct case' do
        expect(page).to have_text(case_number)
      end

      scenario 'has the correct case title' do
        expect(page).to have_text('You vs HM Revenue & Customs')
      end

      scenario 'has the correct amount' do
        expect(page).to have_text('Total amount £20')
      end

      scenario 'has the correct type' do
        expect(page).to have_text('Lodgement Fee')
      end

      describe 'submit' do
        let(:stub_glimr_call) {
          allow(GlimrApiClient::PayByAccount).to receive(:call).with(
            feeLiabilityId: 7,
            pbaAccountNumber: 'ABC123',
            pbaConfirmationCode: 'AC-D3-46',
            pbaTransactionReference: case_number,
            amountToPayInPence: 2000
          )
        }

        let(:fill_form) {
          fill_in 'Account reference', with: 'ABC123'
          fill_in 'Account confirmation code', with: 'AC-D3-46'
          click_on 'Continue'
        }

        scenario 'sends data to glimr and does not require a data response' do
          stub_glimr_call
          fill_form
          expect(page).to have_text('Fee paid via account reference ABC123')
        end

        scenario 'handles bad account references' do
          stub_glimr_call.and_raise(GlimrApiClient::PayByAccount::AccountNotFound)
          fill_form
          expect(page).to have_text('Account not found')
        end

        scenario 'handles bad confirmation codes' do
          stub_glimr_call.and_raise(GlimrApiClient::PayByAccount::InvalidAccountAndConfirmation)
          fill_form
          expect(page).to have_text('Account not found')
        end
      end
    end
  end
end
