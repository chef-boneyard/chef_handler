require 'bundler'

begin
  require 'rspec/core/rake_task'

  task :default => :spec

  desc 'Run all specs in spec directory'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end

rescue LoadError
  STDERR.puts "\n*** RSpec not available. bundle install to run unit tests. ***\n\n"
end
