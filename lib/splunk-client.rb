require 'rest-client'
require 'nokogiri'
require 'yaml'

class SplunkClient
  attr_reader :session_key, :last_job_id

  def initialize
    @opts = YAML::load(File.open('config.yml'))
    @base_url = "https://#{@opts['host']}:#{@opts['port']}/services"
    @session = RestClient::Resource.new(
        @base_url,
        :timeout => 60,
        :open_timeout => 5
    )
    @session_key = authenticate_user
  end

  def authenticate_user
    @auth = @session['/auth/login']
    doc = @auth.post :username=>@opts['username'], :password => @opts['password']
    xml_value(doc, '//sessionKey')
  end
  private :authenticate_user

  def xml_value(doc, xpath)
    Nokogiri::XML.parse(doc).xpath(xpath).first.content
  end
  private :xml_value

  def post path, payload=nil
    puts "POST: #{path}"
    puts "  payload: #{payload}" if payload
    if payload
      @session[path].post payload, :authorization => "Splunk #{@session_key}"
    else
      @session[path].post :authorization => "Splunk #{@session_key}"
    end
  end

  def get path
    puts "GET: #{path}"
    @session[path].get :authorization => "Splunk #{@session_key}"
  end

  def search_results(sid=last_job_id)
    get "/search/jobs/#{sid}/results"
  end

  def search search_parameters
    search = CGI::escape search_parameters
    doc = post "/search/jobs", "search=#{search}"
    @last_job_id = xml_value(doc, '//sid')
  end

  def status(sid=last_job_id)
    doc = get "/search/jobs/#{sid}"
    xml_value(doc, "//s:key[@name='isDone']")
  end

  def wait(sid=last_job_id)
    until status == '1' do
      sleep 3
    end
  end

end
