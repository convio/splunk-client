module Splunk
  module VERSION
    NAME = 'splunk-client'
    STRING = '1.0'
    SUMMARY = "#{NAME}-#{STRING}"
  end
  DEPENDENCIES = [
    ['rest-client'],
    ['nokogiri'],
  ]
end