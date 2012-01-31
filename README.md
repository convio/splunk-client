splunk-client is a very simple interface to do searches in Ruby using the Splunk API

Configuration
-------------

You can configure the authentication and server options in a YAML file

<pre>
  host: [hostname]
  port: [port]
  username: [splunk_user]
  password: [splunk_user_password]
</pre>  

Searches
--------

<pre>
  # Start a session using the login credientials
  splunk = Splunk::Session.new('config.yml')

  # Create a new job. This stores the job id internally and you can wait for
  # it or poll using job.running? You can of course spawn parallel jobs
  job = splunk.search('exception  earliest=-d@d')
  job.wait

  # Results are returned with some NokoGiri xpath searches
  # built in. See nokogiri's documentation for how this works.
  results = job.results
  puts results.doc  # raw xml
  exceptions = results.xpath("//results/result/field[@k='_raw']")
  exceptions.each {|e| puts e.content}
</pre>