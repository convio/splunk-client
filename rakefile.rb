$LOAD_PATH.unshift File.dirname(__FILE__)
sh "bundle install"
require 'bundler/setup'
require 'rubygems'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'rake/gempackagetask'
require 'lib/watirmark_bvt/version'

task :default => [:gem]

# Specification for gem creation
spec = Gem::Specification.new do |s|
    s.name               = WatirmarkBVT::VERSION::NAME
    s.version            = WatirmarkBVT::VERSION::STRING
    s.files              = FileList['lib/**/*'].to_a
    s.author             = 'Hugh McGowan'
    s.email              = 'hmcgowan@convio.com' 
    s.has_rdoc           = true
    s.homepage           = 'http://twiki.convio.com/twiki/bin/view/Engineering/WatirmarkDB'
    s.rubyforge_project  = 'none'
    s.summary            = WatirmarkBVT::VERSION::SUMMARY
    s.description        = "The watirmark_bvt library provides access to BVT configurations"
    WatirmarkBVT::DEPENDENCIES.each do |gem|
      s.add_dependency gem[0], gem[1]
    end
end

Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
  rd.options << "--all"
end
 
RSpec::Core::RakeTask.new do |t|
  t.rcov = false
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts ||= []
  t.rspec_opts << '-fs'
end

package = Rake::GemPackageTask.new(spec) {}
gem = "ruby #{Config::CONFIG['bindir']}\\gem"

desc 'Create the gem'
task :install => :gem do
  sh "#{gem} install --both --no-rdoc --no-ri pkg\\#{package.gem_file}"
end

desc "deploy the gem to the gem server; must be run on on qalin"
task :deploy => :gem do
  sh "#{gem} install --local -i c:\\gem_server --no-ri pkg\\#{package.gem_file} --ignore-dependencies"
end
