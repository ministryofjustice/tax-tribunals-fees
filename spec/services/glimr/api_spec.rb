require 'rails_helper'

RSpec.describe Glimr::Api do
  context 'errors' do
    describe 'will re-raise a Timeout::Error' do
      it 'as Glimr::Api::Unavailable' do
        expect(subject).to receive(:post_handler).and_raise(Timeout::Error)
        expect { subject.post('/blah', {}) }.
          to raise_error(Glimr::Api::Unavailable)
      end
    end

    describe 'will re-raise a SocketError' do
      it 'as Glimr::Api::Unavailable' do
        expect(subject).to receive(:post_handler).and_raise(SocketError)
        expect { subject.post('/blah', {}) }.
          to raise_error(Glimr::Api::Unavailable)
      end
    end
  end
end
