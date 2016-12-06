require 'rails_helper'

RSpec.describe 'Pay for a case with a card', type: :request do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  context 'happy path' do
    specify {
      post '/case_requests/payment_method',
        params: { fee_id: 'abc123', payment_method: 'card' }
      expect(response).to redirect_to('/fees/abc123/pay')
    }
  end
end
