require_relative 'config/application'
Rails.application.load_tasks

task :mutant do
  system 'RAILS_ENV=test mutant -r ./config/environment --use rspec CaseRequest'
end
