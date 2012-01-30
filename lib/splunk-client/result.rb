module Splunk
  class Result
    attr_accessor :doc

    def initialize(doc)
      @doc = doc
    end

    def value_for(x)
      Nokogiri::XML.parse(@doc).xpath("//#{x}").first.content
    end
  end
end