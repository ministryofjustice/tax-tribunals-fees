require 'rails_helper'
require 'support/shared_examples_for_glimr'

RSpec.feature 'Request a case that has already been paid for' do
  include_examples 'glimr availability request', glimrAvailable: 'yes'

  # Because let blocks cannot be passes as arguments to shared examples.
  case_number = 'TC/2012/00001'
  confirmation_code = 'ABC123'

  # Because let blocks are memoized and subsequent calls to not execute the
  # workflow again.
  def make_a_case_request(case_number, confirmation_code)
    visit '/'
    click_on 'Start now'
    fill_in 'Case reference', with: case_number
    fill_in 'Confirmation code', with: confirmation_code
    click_on 'Find case'
  end

  describe 'and there are no new fees' do
    include_examples 'no new fees are due', case_number, confirmation_code

    scenario 'No new fees are recorded locally' do
      expect {
        make_a_case_request(case_number, confirmation_code)
      }.not_to change { Fee.count }
    end

    scenario 'we explain that there are no outstanding fees' do
      make_a_case_request(case_number, confirmation_code)
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).to have_text('There are currently no outstanding fees on your case')
    end
  end

  describe 'and there is a new fee' do
    include_examples 'no fees then a £20 fee', case_number, confirmation_code

    before do
      make_a_case_request(case_number, confirmation_code)
    end

    scenario 'One new fee is recorded locally' do
      expect {
        make_a_case_request(case_number, confirmation_code)
      }.to change { Fee.count }.by(1)
    end

    scenario 'we explain that there are no outstanding fees' do
      make_a_case_request(case_number, confirmation_code)
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).to have_text('£20.00')
    end
  end
end
