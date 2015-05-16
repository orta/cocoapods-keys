require 'bundler/gem_tasks'

dump_keys_tool = 'spec/fixtures/dump-key'
dump_keys_source_file = "#{dump_keys_tool}.m"
file dump_keys_tool => dump_keys_source_file do
  sh "xcrun clang -framework Foundation #{dump_keys_source_file} -o #{dump_keys_tool}"
end

desc "Run tests"
task :spec => dump_keys_tool do
  sh "bundle exec rspec spec/*_spec.rb"
  sh "bundle exec rubocop"
end

task :default => :spec
