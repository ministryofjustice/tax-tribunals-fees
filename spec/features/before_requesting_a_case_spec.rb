require 'rails_helper'
require 'support/shared_examples_for_glimr'

RSpec.feature 'Before requesting a case' do
  context 'Glimr is up' do
    describe 'users can start a new case ' do
      include_examples 'glimr availability request', glimrAvailable: 'yes'
      scenario do
        visit '/'
        expect(page).to have_text('Start now')
      end
    end
  end

  context 'Glimr is down' do
    describe 'users cannot start a new case ' do
      include_examples 'glimr availability request', glimrAvailable: 'no'
      it_behaves_like 'service is not available'
    end

    describe 'when there is a network error' do
      include_examples 'network error'
      it_behaves_like 'service is not available'
    end
  end
end
