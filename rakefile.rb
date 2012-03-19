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
  gemserver=ENV['GEM_SERVER']
  ssh_options='-o User=root -o IdentityFile=~/.ssh/0-default.private -o StrictHostKeyChecking=no -o CheckHostIP=no -o UserKnownHostsFile=/dev/null'
  temp_dir=`ssh #{ssh_options} #{gemserver} 'mktemp -d'`.strip
  system("scp #{ssh_options} pkg/*.gem '#{gemserver}:#{temp_dir}'")
  system("ssh #{ssh_options} #{gemserver} 'gem install --local --no-ri #{temp_dir}/*.gem --ignore-dependencies'")
  system("ssh #{ssh_options} #{gemserver} 'rm -rf #{temp_dir}'")
end

