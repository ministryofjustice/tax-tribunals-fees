require 'rails_helper'

RSpec.describe Status do
  let(:glimr_available) {
    instance_double(GlimrApiClient::Available, available?: true)
  }

  let(:status) do
    {
      service_status: service_status,
      version: 'ABC123',
      dependencies: {
        glimr_status: glimr_status,
        database_status: database_status,
        govuk_pay_status: govuk_pay_status
      }
    }
  end

  # Default is everything is fine
  let(:service_status) { 'ok' }
  let(:glimr_status) { 'ok' }
  let(:database_status) { 'ok' }
  let(:govuk_pay_status) { 'ok' }

  before do
    allow(GlimrApiClient::Available).to receive(:call).and_return(glimr_available)
    allow(ActiveRecord::Base).to receive(:connection).and_return(double)
    allow(Excon).to receive(:get).and_return(object_double('response', body: '{"ping":{"healthy":true},"deadlocks":{"healthy":true}}'))
    # These are expediencies to avoid having to add multiple extra stubs to
    # check something low-priority.
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:`).with('git rev-parse HEAD').and_return('ABC123')
    # rubocop:enable RSpec/AnyInstance
  end

  describe '.version' do
    # Necessary evil for coverage purposes.
    it 'calls `git rev-parse HEAD`' do
      # See above
      # rubocop:disable RSpec/AnyInstance
      expect_any_instance_of(described_class).to receive(:`).with('git rev-parse HEAD').and_return('ABC123')
      # rubocop:enable RSpec/AnyInstance
      described_class.check
    end
  end

  describe '#check' do
    context 'service normal' do
      specify { expect(described_class.check).to eq(status) }
    end

    context 'glimr unavailable' do
      let(:service_status) { 'failed' }
      let(:glimr_status) { 'failed' }

      before do
        allow(GlimrApiClient::Available).to receive(:call).and_raise(GlimrApiClient::Unavailable)
      end

      specify { expect(described_class.check).to eq(status) }
    end

    context 'database unavailable' do
      let(:service_status) { 'failed' }
      let(:database_status) { 'failed' }

      before do
        expect(ActiveRecord::Base).to receive(:connection).and_return(nil)
      end

      specify { expect(described_class.check).to eq(status) }
    end

    context 'govuk pay unavailable - ping failed' do
      let(:service_status) { 'failed' }
      let(:govuk_pay_status) { 'failed' }

      before do
        allow(Excon).to receive(:get).and_return(object_double('response', body: '{"ping":{"healthy":false},"deadlocks":{"healthy":true}}'))
      end

      specify { expect(described_class.check).to eq(status) }
    end

    context 'govuk pay unavailable - deadlocks failed' do
      let(:service_status) { 'failed' }
      let(:govuk_pay_status) { 'failed' }

      before do
        allow(Excon).to receive(:get).and_return(object_double('response', body: '{"ping":{"healthy":true},"deadlocks":{"healthy":false}}'))
      end

      specify { expect(described_class.check).to eq(status) }
    end

    context 'govuk pay unavailable - both failed' do
      let(:service_status) { 'failed' }
      let(:govuk_pay_status) { 'failed' }

      before do
        allow(Excon).to receive(:get).and_return(object_double('response', body: '{"ping":{"healthy":false},"deadlocks":{"healthy":false}}'))
      end

      specify { expect(described_class.check).to eq(status) }
    end

    context 'govuk pay unavailable - blank response' do
      let(:service_status) { 'failed' }
      let(:govuk_pay_status) { 'failed' }

      before do
        allow(Excon).to receive(:get).and_return(object_double('response', body: ''))
      end

      specify { expect(described_class.check).to eq(status) }
    end
  end
end
