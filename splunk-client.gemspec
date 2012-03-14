$:.unshift File.expand_path("../lib", __FILE__)
require "splunk-client/version"

Gem::Specification.new do |s|
  name = Splunk::VERSION::NAME
  s.name = name
  version = Splunk::VERSION::STRING
  s.version = version
  s.authors = [%q{Hugh McGowan}]
  s.email = %q{hmcgowan@convio.com}
  s.description = %q{splunk-client allows a user to do simple searches against a splunk instance}
  s.homepage = %q{http://twiki.convio.com/twiki/bin/view/Engineering}
  s.summary = %Q{splunk #{version}}
  s.files = Dir['lib/**/*']
  s.test_files =  Dir['spec/**/*.rb']
  s.require_paths = ["lib"]
  Splunk::DEPENDENCIES.each do |gem|
    s.add_dependency gem[0], gem[1]
  end

end