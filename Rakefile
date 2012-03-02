require "bundler/gem_tasks"

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec

begin
	require 'yard'
	desc "Run the YARDdoc task"
	task :yard do
		exec "yardoc --plugin yard-tomdoc"
	end
rescue LoadError
	puts "Please install the Yard gem to create docs"
end
