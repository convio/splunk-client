require 'rest-client'
require 'nokogiri'
require 'yaml'

module Splunk

  module SplunkHelper
    def xpath_content(doc, xpath)
      Nokogiri::XML.parse(doc).xpath(xpath).first.content
    end
    private :xpath_content

    def post path, payload=nil
      if payload
        @session[path].post payload, :authorization => "Splunk #{@session_key}"
      else
        @session[path].post :authorization => "Splunk #{@session_key}"
      end
    end
    private :post

    def get path
      @session[path].get :authorization => "Splunk #{@session_key}"
    end
    private :get
  end

  class Job
    include SplunkHelper
    attr_accessor :id

    def initialize(session, session_key, id)
      @session = session
      @session_key = session_key
      @id = id
    end

    def running?
      status == '0'
    end

    def status
      doc = get("/search/jobs/#{@id}")
      xpath_content(doc, "//s:key[@name='isDone']")
    end

    def results
      get "/search/jobs/#{@id}/results"
    end

    def wait(timeout=120)
      Timeout::timeout(timeout) do
        sleep 1 while running?
      end
    end
  end

  class Client
    include SplunkHelper
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
      @jobs = []
    end

    def authenticate_user
      @auth = @session['/auth/login']
      doc = @auth.post :username=>@opts['username'], :password => @opts['password']
      xpath_content(doc, '//sessionKey')
    end
    private :authenticate_user

    def search search_parameters
      search = CGI::escape search_parameters
      doc = post "/search/jobs", "search=#{search}"
      job_id = xpath_content(doc, '//sid')
      Job.new(@session, @session_key, job_id)
    end
  end
end