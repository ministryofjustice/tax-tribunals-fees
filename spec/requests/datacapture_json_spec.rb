require 'rails_helper'

RSpec.describe 'Hypermedia link for datacapture api call', type: :request do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

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
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
  end

  describe 'happy path' do
    let(:request_details) {
      { case_request: { case_reference: 'ABC123', confirmation_code: 'A1-B2-C3' } }
    }

    let(:headers) {
      { 'CONTENT_TYPE' => 'application/json' }
    }

    before do
      allow(CaseRequest).to receive(:new).and_return(instance_double(CaseRequest, id: 'ABC123').as_null_object)
    end

    it 'return a url for redirecting the user' do
      post '/case_requests',
        params: request_details,
        headers: headers,
        as: :json
      expect(response.body).to eq('{"return_url":"http://www.example.com/case_requests/ABC123"}')
    end
  end
end
