require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/clean'
CLEAN << FileList["pkg", "coverage"]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Splunk #{Splunk::VERSION::STRING}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "deploy the gem to the gem server; must be run on on gem server"
task :deploy => [:clean, :install] do
  sh "gem install --local --no-ri ./pkg/* --ignore-dependencies"
end
