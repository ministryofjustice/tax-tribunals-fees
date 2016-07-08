require 'rails_helper'

RSpec.describe Glimr::Requests::CaseFees do
  subject {
    described_class.new(case_reference: 'TT123', confirmation_code: 1234)
  }

  describe '#call' do
    context 'successful' do
      before do
        stub_request(:post, %r[/api/tdsapi/requestpayablecasefees$]).
          with(body: "jurisdictionId=8&caseNumber=TT123&caseConfirmationCode=1234",
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 200)
      end

      it 'creates a new Responses::CaseFees instance' do
        expect(subject.call).to be_an_instance_of(Glimr::Responses::CaseFees)
      end
    end

    context 'unsuccessful' do
      before do
        stub_request(:post, %r[/api/tdsapi/requestpayablecasefees$]).
          with(body: "jurisdictionId=8&caseNumber=TT123&caseConfirmationCode=1234",
               headers: { 'Accept' => 'application/json' }).
          to_return(status: 404)
      end

      it 'creates a new Responses::CaseNotFound instance' do
        expect(subject.call).to be_an_instance_of(Glimr::Responses::CaseNotFound)
      end
    end
  end
end
