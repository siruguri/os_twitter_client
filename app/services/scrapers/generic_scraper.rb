require 'open-uri'

module Scrapers
  class GenericScraper
    def get_dom(uri_string)
      handle = open(uri_string)
      SafeDom.new(Nokogiri::HTML.parse(handle.readlines.join('')))
    end
  end
end
