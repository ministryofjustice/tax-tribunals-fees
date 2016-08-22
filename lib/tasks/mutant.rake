
def classes_to_mutate
  Rails.initialize!
  Rails.application.eager_load!
  ['app/models', 'app/operations'].map { |dir|
    grep_dir_for_classes(dir)
  }.flatten
end

# Grepping through the source code is a nasty hack, but it works.
# The purpose is so that developers don't need to remember to add
# new classes to a list for mutation testing.
def grep_dir_for_classes(dir)
  re = /class (?<klass>\w+)/

  Dir.glob(Rails.root.join("#{dir}/*.rb")).
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
