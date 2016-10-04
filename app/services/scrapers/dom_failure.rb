module Scrapers
  class DomFailure < Exception
    attr_reader :failed_pattern

    def initialize(p)
      @failed_pattern = p
    end
    
    def message
      "Extraction failed at #{@failed_pattern}"
    end
  end
end
