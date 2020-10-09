begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:lint)
rescue LoadError
end

task :default => [:spec, :lint]
