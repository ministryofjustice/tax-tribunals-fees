require 'rails_helper'

RSpec.describe Glimr::Api do
  subject { described_class.new }

  context 'errors' do
    describe 'will re-raise a Timeout::Error' do
      it 'as Glimr::Api::Unavailable' do
        expect(subject).to receive(:post_handler).and_raise(Timeout::Error)
      end

      it 'a Responses::ApiError object get returned' do
        expect(subject.post('test', 'test')).
          to be_an_instance_of(Glimr::Responses::ApiError)
      end
    end

    describe 'will re-raise a SocketError' do
      it 'as Glimr::Api::Unavailable' do
        expect(subject).to receive(:post_handler).and_raise(SocketError)
      end

      it 'a Responses::ApiError object get returned' do
        expect(subject.post('test', 'test')).
          to be_an_instance_of(Glimr::Responses::ApiError)
      end
    end
  end
end
