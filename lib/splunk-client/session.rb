module Splunk
  class Session
    attr_reader :site, :key

    def initialize
      @opts = YAML::load(File.open('config.yml'))
      @base_url = "https://#{@opts['host']}:#{@opts['port']}/services"
      @site = RestClient::Resource.new(@base_url, :timeout => 60, :open_timeout => 5)
      @key = authenticate_user
    end

    def authenticate_user
      @auth = @site['/auth/login']
      doc = @auth.post :username=>@opts['username'], :password => @opts['password']
      Result.new(doc).value_for('//sessionKey')
    end

    private :authenticate_user

    def search search_parameters
      search = CGI::escape search_parameters
      result = post "/search/jobs", "search=#{search}"
      Job.new(self, result.value_for('//sid'))
    end

    def post path, payload=nil
      if payload
        doc = @site[path].post payload, :authorization => "Splunk #{@key}"
      else
        doc = @site[path].post :authorization => "Splunk #{@key}"
      end
      Result.new(doc)
    end

    def get path
      doc = @site[path].get :authorization => "Splunk #{@key}"
      Result.new(doc)
    end

  end
end