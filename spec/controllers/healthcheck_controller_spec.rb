require 'rails_helper'

RSpec.describe HealthcheckController do
  let(:status) do
    {
      service_status: 'ok',
      version: 'ABC123',
      dependencies: {
        glimr_status: 'ok',
        database_status: 'ok',
        govuk_pay_status: 'ok'
      }
    }.to_json
  end

  before do
    # Stubbing GlimrApiClient does not work here for some reason Stubbing
    # GlimrApiClient does not work here for some reason that isn't clear.
    stub_request(:post, /glimravailable/).
      to_return(body: { glimrAvailable: 'yes' }.to_json)
    stub_request(:get, /healthcheck/).
      to_return(body: '{"ping":{"healthy":true},"deadlocks":{"healthy":true}}')
    expect(ActiveRecord::Base).to receive(:connection).and_return(double)
    # This is an expediency to avoid having to add multiple extra stubs to
    # check something low-priority.
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Healthcheck).to receive(:version).and_return('ABC123')
    # rubocop:enable RSpec/AnyInstance
  end

  # This is very-happy-path to ensure the controller responds.  The bulk of the
  # healthcheck is tested in spec/services/healthcheck_spec.rb.
  describe '#index' do
    describe 'happy path' do
      before do
        get :index, format: :json
      end

      specify do
        expect(response.status).to eq(200)
      end

      specify do
        expect(response.body).to eq(status)
      end
    end
  end
end
