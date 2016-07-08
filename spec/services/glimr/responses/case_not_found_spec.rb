require 'rails_helper'

RSpec.describe Glimr::Responses::CaseNotFound do
  let(:glimr_response) {
    {
      'glimrerrorcode' => 'error',
      'message' => 'something happened'
    }
  }

  subject { described_class.new(glimr_response) }

  describe '#error_code' do
    it 'exposes the error class' do
      expect(subject.error_code).to eq(glimr_response['glimrerrorcode'])
    end
  end

  describe '#error_message' do
    it 'exposes the error message' do
      expect(subject.error_message).to eq(glimr_response['message'])
    end
  end

  describe '#error?' do
    it { expect(subject.error?).to be_truthy }
  end
end
