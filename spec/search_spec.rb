$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'splunk-client'

describe 'Search' do

  before :all do
    @splunk = Splunk::Client.new
    search_terms = "search exception earliest=-1d@d"
    search_terms << "| regex host=\"bvt3\\w+\\d+\""
    @job = @splunk.search(search_terms)
  end

  specify 'should be able to get a valid session key' do
    @splunk.session_key.should_not be_nil
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
end