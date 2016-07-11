require 'database_cleaner'
require 'factory_girl'
namespace :factory_girl do
  desc 'Verify that all FactoryGirl factories are valid'
  task lint: :environment do
    sh 'bin/rails db:environment:set RAILS_ENV=test'
    Rails.env = 'test'
    FactoryGirl.lint
  end
end

task(:default).prerequisites.unshift task('factory_girl:lint')
