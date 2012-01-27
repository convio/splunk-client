require 'rest-client'
require 'nokogiri'
require 'yaml'

class SplunkClient
  attr_reader :session_key

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

  def request path, payload=nil
    puts "Request: #{path}"
    puts "  payload: #{payload}" if payload
    if payload
      @session[path].post payload, :authorization => "Splunk #{@session_key}"
    else
      @session[path].post :authorization => "Splunk #{@session_key}"
    end
  end

  def search_results(sid)
    request "/search/jobs/#{sid}/events"
  end

  def search search_parameters
    search = CGI::escape search_parameters
    doc = request "/search/jobs", "search=#{search}"
    xml_value(doc, '//sid')
  end

  def jobs
    request '/search/jobs'
  end

end
