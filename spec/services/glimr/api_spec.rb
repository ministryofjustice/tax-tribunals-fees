require 'rails_helper'

RSpec.describe Glimr::Api do
  subject { described_class.new }

  describe '#post' do
    context 'when a SocketError occurs' do
      before do
        allow(subject.class).to receive(:post).and_raise(SocketError)
      end

      it 'a Responses::ApiError object get returned' do
        expect(subject.post('test', 'test')).
          to be_an_instance_of(Glimr::Responses::ApiError)
      end
    end

    context 'when a TimeoutError occurs' do
      before do
        allow(subject.class).to receive(:post).and_raise(Timeout::Error)
      end

      it 'a Responses::ApiError object get returned' do
        expect(subject.post('test', 'test')).
          to be_an_instance_of(Glimr::Responses::ApiError)
      end
    end
  end
end
