require 'rails_helper'

RSpec.describe ProcessPayByAccount do
  context 'errors' do
    let!(:fee) { create(:fee) }

    context 'where the API client raises an exception' do
      before do
        allow(GlimrApiClient::PayByAccount).
          to receive(:call).
          and_raise(GlimrApiClient::PayByAccount::FeeLiabilityNotFound)
      end

      # rubocop:disable RSpec/MultipleExpectations
      # Different kind of expectations...
      specify 'are logged and re-raised' do
        expect(Rails.logger).to receive(:error).with(/FeeLiabilityNotFound/)

        expect {
          described_class.call(fee.id, reference: 'B', confirmation: 'B')
        }.to raise_error(GlimrApiClient::PayByAccount::FeeLiabilityNotFound)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
