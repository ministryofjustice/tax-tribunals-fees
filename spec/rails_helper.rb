ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
# This is not being used to mock api calls, but to ensure that there aren't any
# that slip by unnoticed. Specs that depend on API calls which are not
# otherwise mocked may not fail in on the MoJ network, but may fail in CI and
# other locations.
require 'webmock/rspec'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryGirl::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:each) do
    I18n.locale = I18n.default_locale
  end
end
