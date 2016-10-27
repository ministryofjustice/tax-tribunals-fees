require 'rails_helper'

RSpec.feature 'Before requesting a case' do
  context 'Glimr is up' do
    before do
      allow(GlimrApiClient::Available).to receive_message_chain([:call, :available?]).and_return(true)
    end

    describe 'users can start a new case ' do
      scenario do
        visit '/'
        expect(page).to have_text('Start now')
      end
    end
  end

  context 'Glimr is down' do
    describe 'users cannot start a new case ' do
      before do
        allow(GlimrApiClient::Available).to receive_message_chain([:call, :available?]).and_raise(GlimrApiClient::Unavailable)
      end

      scenario 'and are told the service is unavailable' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end
end
