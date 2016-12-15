require 'rails_helper'

# This functionality is largely covered by the feature specs. This spec, which
# only covers the bare-bones of the show action, is here for completeness.
RSpec.describe CaseRequestsController, '#show' do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }
  let!(:case_request) { create(:case_request_with_fee) }

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
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
    allow(GlimrApiClient::Case).to receive(:find).and_return(glimr_case)
  end

  describe 'happy path' do
    before do
      get case_request_url(case_request)
    end

    it 'shows that a fee is due' do
      expect(response.body).to include('You need to pay the following fee')
    end

    scenario 'show the case reference' do
      expect(response.body).to include(case_request.case_reference)
    end
  end

  context 'case not found' do
    it 'redirects to new' do
      get case_request_url('junk')
      expect(response).to redirect_to(new_case_request_url)
    end

    it 'explains the error' do
      get case_request_url('junk')
      follow_redirect!
      expect(response.body).to include('Case not found')
    end
  end
end
