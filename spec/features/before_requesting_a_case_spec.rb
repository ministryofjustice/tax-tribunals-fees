require 'rails_helper'

RSpec.describe 'Before requesting a case' do
  context 'Glimr is up' do
    let(:api_available) { instance_double(GlimrApiClient::Available, available?: true) }

    before do
      allow(GlimrApiClient::Available).to receive(:call).and_return(api_available)
    end

    describe 'users can start a new case ' do
      it do
        visit '/'
        expect(page).to have_text('Start now')
      end
    end
  end

  context 'Glimr is down' do
    let(:api_down) { instance_double(GlimrApiClient::Available) }

    before do
      allow(api_down).to receive(:available?).and_raise(GlimrApiClient::Unavailable)
      allow(GlimrApiClient::Available).to receive(:call).and_return(api_down)
    end

    describe 'users cannot start a new case ' do
      it 'and are told the service is unavailable' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end
end
