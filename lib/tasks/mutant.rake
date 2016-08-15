CLASSES = [
  'CaseRequest'
].freeze

task :mutant do
  CLASSES.each do |klass|
    system "RAILS_ENV=test mutant -r ./config/environment --use rspec #{klass}"
  end
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << task(:mutant)
end
