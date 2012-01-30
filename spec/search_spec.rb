$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'splunk-client'

describe 'Search' do

  before :all do
    @splunk = Splunk::Session.new
    search_terms = "search host=\"bvt3*\" site-309 exception earliest=-d@d "
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
    @job.results.xpath("//results/result/field[@k='_raw']").size.should > 0
#    @job.results.xpath("//results/result/field[@k='_raw']").each {|f| puts f.content; puts}
  end



end