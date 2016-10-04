require 'open-uri'

module Scrapers
  class AldailyScraper < GenericScraper
    # Scraper for the AL Daily.com page
    def payload
      @_safe_d = get_dom('http://www.aldaily.com')

      begin
        ret = {status: 'success'}.merge(extract_top3_articles)
      rescue DomFailure => e
        ret = {status: "Failure: #{e.message}"}
      end

      ret
    end

    private
    def extract_top3_articles
      link_divs = []

      first_2_links = @_safe_d.try_css('.col-md-3 p:nth-child(2) a')
      first_2_links.each { |l| link_divs << l }
      link_divs << @_safe_d.try_css('.col-md-4 p:nth-child(2) a')[0]
      
      refs = link_divs.map do |anchor|
        anchor.attribute('href')
      end

      {links: refs}
    end
  end
end
