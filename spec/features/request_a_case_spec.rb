require 'rails_helper'
require 'support/shared_examples_for_glimr'

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
      include_examples 'a case fee of £20 is due', case_number, confirmation_code

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
      include_examples 'generic glimr response',
        case_number,
        confirmation_code,
        418,
        glimrerrorcode: 418, message: 'I’m a teapot'

      scenario 'then we do not show the fee' do
        make_a_case_request
        # TODO: This is not ideal.  It should alert the user to the failure.
        expect(page).to have_text('service is currently unavailable')
      end
    end

    describe 'and glimr times out' do
      let(:excon) {
        class_double(Excon)
      }

      before do
        expect(excon).to receive(:post).and_raise(Excon::Errors::Timeout)
        expect(Excon).to receive(:new).and_return(excon)
      end

      scenario 'we alert the user' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end

  context 'user sends bad data' do
    before do
      visit '/'
      click_on 'Start now'
    end

    describe 'a bad case reference' do
      include_examples 'case not found'

      scenario 'then tell the user the case cannot be found' do
        fill_in 'Case reference', with: 'some junk'
        fill_in 'Confirmation code', with: 'ABC123'
        click_on 'Find case'
        expect(page).to have_text(/we could not find your case/i)
      end
    end

    describe 'a non-existent case' do
      include_examples 'case not found'

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
