source 'https://rubygems.org'

gem 'bcrypt', '~> 3.1.7'
gem 'govuk_elements_rails'
gem 'govuk_elements_form_builder', git: 'https://github.com/ministryofjustice/govuk_elements_form_builder.git'
gem 'govuk_frontend_toolkit'
gem 'govuk_template'
gem 'high_voltage'
gem 'httparty'
gem 'lograge'
gem 'pg'
gem 'pry-rails'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5.0.0'
gem 'redis', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

group :production do
  gem 'rails_12factor'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'launchy'
  gem 'pry-byebug'
  gem 'rspec-rails'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'brakeman'
  gem 'capybara'
  gem 'fuubar'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'webmock'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
