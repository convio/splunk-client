$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'splunk-client'

describe 'Init' do
  specify 'read from file' do
    lambda{
      Splunk::Session.new(File.dirname(__FILE__) + '/config.yml')
    }.should_not raise_error
  end

  specify 'read from string' do
    lambda {
      opts = File.open(File.dirname(__FILE__) + '/config.yml')
      opts =  YAML.load(opts)
      Splunk::Session.new(opts.to_yaml)
    }.should_not raise_error
  end
end

describe 'Search' do

  before :all do
    @splunk = Splunk::Session.new(File.dirname(__FILE__) + '/config.yml')
    search_terms = "search host=\"bvt3*\" Site-309 *Exception "
    search_terms << " NOT ServletProcessTimeException NOT CVSiteSession NOT \"cannot insert NULL\" earliest=-d@d"
    search_terms << "| rex field=_raw \"(?<exception_name>[a-zA-Z\.]+Exception):\" | dedup exception_name"
    @job = @splunk.search(search_terms)
  end

  specify 'should be able to get a valid session key' do
    @splunk.key.should_not be_nil
  end

  specify 'search should return a job id' do
    @job.id.should_not be_nil
  end

  specify 'should return a 1 or 0 for job completion' do
    @job.status.should =~ /^(1|0)$/
  end

  specify 'should be able to give job running status' do
    @job.running?.to_s.should =~ /^(true|false)$/
  end

  specify 'should wait for results' do
    @job.wait
    @job.results.should_not be_nil
  end

  specify 'results should provide xml' do
    @job.results.doc.should_not be_nil
  end

  specify 'should find exceptions' do
    exceptions = @job.results.xpath("//results/result/field[@k='_raw']")
    exceptions.size.should > 0
    puts '------------------------------------'
    puts "Found #{exceptions.size} exceptions"
    puts '------------------------------------'
    exceptions.each {|f| puts f.content; puts}
  end

end