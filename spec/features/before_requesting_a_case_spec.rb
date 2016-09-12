require 'rails_helper'
require 'support/shared_examples_for_glimr'

RSpec.feature 'Before requesting a case' do
  context 'Glimr is up' do # This is the default in rails_helper.
    describe 'users can start a new case ' do
      scenario do
        visit '/'
        expect(page).to have_text('Start now')
      end
    end
  end

  context 'Glimr is down' do
    describe 'users cannot start a new case ' do
      include_examples 'glimr availability request', glimrAvailable: 'no'

      scenario 'and are told the service is unavailable' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end

    describe 'when there is a network error' do
      include_examples 'glimr has a socket error'

      scenario 'and users are told the service is unavailable' do
        visit '/'
        expect(page).to have_text('The service is currently unavailable')
      end
    end
  end
end
