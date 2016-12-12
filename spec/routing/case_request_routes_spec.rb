require 'rails_helper'

RSpec.describe 'case request routes', type: :routing do
  context 'Help With Fees' do
    it 'routes /case_requests/help_with_fees to CaseRequests controller' do
      expect(post('/case_requests/help_with_fees')).
        to route_to('case_requests#help_with_fees')
    end
  end
end
