require 'rails_helper'
require 'support/shared_examples_for_paid_liabilities'

RSpec.feature 'Request a case with paid liabilities' do

  describe 'and no new liabilities exist' do
    include_examples 'a £20 fee followed by no new fees'

    scenario 'we reuse the existing case request' do
      expect {
        2.times do
          make_a_case_request
        end
      }.not_to change { CaseRequest.count }.from(1)
    end

    scenario 'we explain that all payments are up-to-date' do
      make_a_case_request
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).to have_text('£20.00 Lodgement Fee')
      pay_liabilities
      make_a_case_request
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).to have_text('All outstanding fee payments are up to date')
      expect(page).to have_text('other fees may be payable at a later date')
    end
  end
end

RSpec.feature 'Request a case with paid liabilities ' do
  describe 'and there is a new liability' do
    scenario 'we reuse the existing case request' do
      expect { make_a_case_request }.not_to change { CaseRequest.count }
    end

    scenario 'then we show the fee' do
      make_a_case_request
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).to have_text('£20.00')
    end
  end

  describe 'and there is a duplicate liability' do
    scenario 'then we show the fee the first time but not the second' do
      make_a_case_request
      expect(page).to have_text('You vs HM Revenue & Customs')
      expect(page).not_to have_text('£20.00')
    end
  end
end
