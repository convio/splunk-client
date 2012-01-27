SplunkClient is a very simple interface to do searches in Ruby using the Splunk API

This implementation is in progress so does not yet have a complete end-to-end search...yet...

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
  splunk = SplunkClient.new
  job_id = splunk.search 'search exception earliest=-1d@d'
  ...remaining code in progress...
</pre>  
