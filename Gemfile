source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'bcrypt', '~> 3.1.7'
gem 'excon'
gem 'glimr-api-client', '0.2.4'
gem 'govuk-pay-api-client', '0.1.5'
gem 'govuk_elements_form_builder', github: 'ministryofjustice/govuk_elements_form_builder', ref: '9128562'
gem 'govuk_elements_rails', '2.0.0'
gem 'govuk_frontend_toolkit', '5.0.2'
gem 'govuk_template', '0.19.1'
gem 'high_voltage'
gem 'httparty'
gem 'lograge'
gem 'pg'
gem 'pry-rails'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.0.0'
gem 'redis', '~> 3.0'
gem 'responders'
gem 'sass-rails', '~> 5.0'
gem 'sentry-raven'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'launchy'
  gem 'mutant-rspec'
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'web-console'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
