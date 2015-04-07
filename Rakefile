require 'bundler/gem_tasks'
require "rspec/core/rake_task"

dump_keys_tool = 'spec/fixtures/dump-key'
dump_keys_source_file = "#{dump_keys_tool}.m"
file dump_keys_tool => dump_keys_source_file do
  sh "xcrun clang -framework Foundation #{dump_keys_source_file} -o #{dump_keys_tool}"
end

RSpec::Core::RakeTask.new(:spec => dump_keys_tool)

task :default => :spec
