require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'

Bundler.require(*Rails.groups)

module TaxTribunalsFees
  class Application < Rails::Application
    config.i18n.load_path =
      Dir[Rails.root.join('config', 'locales', '{en}', '*.yml').to_s]
    config.i18n.default_locale = :en
    config.assets.precompile += %w[
      application.css
      application-ie8.css
      application-ie7.css
      application-ie6.css
      application.js
    ]
  end
end
