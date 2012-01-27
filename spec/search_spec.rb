$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'splunk-client'

describe 'Search' do

  before :all do
    @splunk = SplunkClient.new
  end

  specify 'should be able to get a valid session key' do
    @splunk.session_key.should_not be_nil
  end

  specify 'search should return a job id' do
    search_terms = "regex host=\"bvt3\w+\d+\""
    search_terms << "| search exception earliest=-1d@d"
    search_terms << "| rex field=_raw \"(?<exception_name>[a-zA-Z\.]+Exception:.+)\""
    job_id = @splunk.search(search_terms)
    job_id.should_not be_nil
  end
end