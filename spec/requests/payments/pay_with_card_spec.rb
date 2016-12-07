require 'rails_helper'

RSpec.describe 'pay by card spec', type: :request do
  let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
  end

  context 'happy path' do
    specify {
      put '/payment_methods/abc123', params: { payment_method: 'card' }
      expect(response).to redirect_to('/fees/abc123/pay')
    }
  end
end
