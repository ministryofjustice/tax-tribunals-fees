require_relative 'application'
Rails.application.initialize!

# Gov UK pay will redirect back to this host. This env var must be set
# in production but is not required in dev & test
Rails.application.routes.default_url_options[:host] =
  ENV.fetch('GOV_UK_REDIRECT_HOST')
