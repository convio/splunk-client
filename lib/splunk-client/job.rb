module Splunk
  class Job
    attr_accessor :id

    def initialize(session, id)
      @session = session
      @id = id
    end

    def running?
      status == '0'
    end

    def status
      @session.get("/search/jobs/#{@id}").value_for("//s:key[@name='isDone']")
    end

    def results
      @session.get("/search/jobs/#{@id}/results")
    end

    def wait(timeout=120)
      Timeout::timeout(timeout) do
        sleep 1 while running?
      end
    end
  end

end
