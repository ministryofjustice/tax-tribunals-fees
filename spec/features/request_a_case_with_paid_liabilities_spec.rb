require 'rails_helper'
require 'shared_examples_for_glimr'

RSpec.feature 'Request a case with paid liabilities ' do
  include_examples 'glimr availability request', glimrAvailable: 'yes'

  let!(:case_request) {
    # Webmock is set to match this case reference.
    create(:case_request_with_paid_liabilities, case_reference: 'TC/2012/00001')
  }

  let(:make_a_case_request) {
    visit '/'
    click_on 'Start now'
    fill_in 'Case Reference', with: case_request.case_reference
    fill_in 'Confirmation Code', with: 'ABC123'
    click_on 'Find Case'
  }

  describe 'and no new liabilities exist' do
    include_examples 'request payable case fees', 200,
      'jurisdictionId' => 8,
      'tribunalCaseId' => 60_029,
      'caseTitle' => 'You vs HM Revenue & Customs',
      'feeLiabilities' => []

    scenario 'we reuse the existing case request' do
      expect { make_a_case_request }.not_to change { CaseRequest.count }
    end

    scenario 'we explain that all payments are up-to-date' do
      make_a_case_request
      expect(page).to have_text('You vs HMRC')
      expect(page).to have_text('All outstanding fee payments are up to date')
      expect(page).to have_text('other fees may be payable at a later date')
    end
  end
end
