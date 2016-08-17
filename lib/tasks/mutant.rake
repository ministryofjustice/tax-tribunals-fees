CLASSES = %w[
  CaseRequest
  Fee
].freeze

task :mutant do
  CLASSES.each do |klass|
    vars = 'RAILS_ENV=test NOCOVERAGE=true'
    flags = '--use rspec --fail-fast'
    unless system("#{vars} mutant -r ./config/environment #{flags} #{klass}")
      raise 'Mutation testing failed'
    end
  end
end

if %w[development test].include? Rails.env
  task(:default).prerequisites << task(:mutant)
end
