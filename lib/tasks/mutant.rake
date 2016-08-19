
def classes_to_mutate
  Rails.initialize!
  Rails.application.eager_load!
  grep_model_files_for_classes
end

# This is a nasty hack. If we didn't have PORO models, we could just use
# ApplicationRecord.descendants, but that wouldn't pick up e.g. CaseRequest
#
# Grepping through the source code seemed to be the most pragmatic solution
# so that developers don't need to remember to add new classes to a list for
# mutation testing, but it's not ideal
def grep_model_files_for_classes
  re = /class (?<klass>\w+)/

  Dir.glob(Rails.root.join('app/models/*.rb')).
    map { |f| File.readlines(f).grep(/\bclass /) }.flatten.
    map { |s| re.match(s)[:klass] }.map(&:constantize).
    reject do |klass|
      klass.respond_to?(:abstract_class?) && klass.abstract_class?
    end
end

task :mutant do
  classes_to_mutate.each do |klass|
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
