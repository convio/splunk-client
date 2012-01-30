module Splunk
  class Result
    attr_accessor :doc

    def initialize(doc)
      @doc = doc
    end

    def xpath(xpath)
      Nokogiri::XML.parse(doc).xpath(xpath)
    end

    def value_for(xpath)
      xpath(xpath).first.content
    end
  end
end

