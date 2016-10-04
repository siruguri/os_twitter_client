module Scrapers
  class SafeDom
    # Wrapper class to implement parser management
    def initialize(dom_or_ns)
      @_dom_or_ns = dom_or_ns
    end
    
    def try_css(patt)
      if (ret=@_dom_or_ns.css(patt)).empty?
        raise DomFailure.new(patt)
      else
        ret
      end
    end

    def try_xpath(patt)
      if (ret=@_dom_or_ns.xpath(patt)).empty?
        raise DomFailure.new(patt)
      else
        ret
      end
    end

    def xpath(patt)
      @_dom_or_ns.xpath patt
    end
  end
end
