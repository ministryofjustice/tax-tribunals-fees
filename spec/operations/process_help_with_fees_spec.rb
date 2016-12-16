require 'rails_helper'

RSpec.describe ProcessHelpWithFees do
  context 'errors' do
    let!(:fee) { create(:fee) }

    context 'where the API client raises an exception' do
      before do
        allow(GlimrApiClient::HwfRequested).
          to receive(:call).
          and_raise(GlimrApiClient::HwfRequested::FeeLiabilityNotFound)
      end

      # rubocop:disable RSpec/MultipleExpectations
      # Different kind of expectations...
      specify 'are logged and re-raised' do
        expect(Rails.logger).to receive(:error).with(/FeeLiabilityNotFound/)

        expect {
          described_class.call(fee.id)
        }.to raise_error(GlimrApiClient::HwfRequested::FeeLiabilityNotFound)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
