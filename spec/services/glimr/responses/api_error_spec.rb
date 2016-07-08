require 'rails_helper'

RSpec.describe Glimr::Responses::ApiError do
  let(:error) { Timeout::Error.new('timed out') }
  subject { described_class.new(error) }

  describe '#error_code' do
    it 'exposes the error class' do
      expect(subject.error_code).to eq(error.class)
    end
  end

  describe '#error_message' do
    it 'exposes the error message' do
      expect(subject.error_message).to eq(error.message)
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_truthy }
  end
end
