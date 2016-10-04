module Scrapers
  class RedditScraper < GenericScraper
    class RedditUserInfo < ScraperExtractionInfo
      include Enumerable
      attr_reader :error
      
      # User info with keys subreddit_counts, submitted_links, and entries list; #extracted? return true or false
      def initialize(options = {})
        @_store = {submitted_links: 0, entries: [], subreddit_counts: {}}
        if options[:error]
          @error=options[:error]
        end
      end

      def aggregate!(hash)
        if hash[:submitted_links]
          @_store[:submitted_links] += hash[:submitted_links]
        end

        if hash[:entries]
          @_store[:entries] += hash[:entries]
        end

        @_store[:entries].each do |entry_hash|
          @_store[:subreddit_counts]["#{entry_hash[:subreddit]}.#{entry_hash[:post_type]}"] ||= 0
          @_store[:subreddit_counts]["#{entry_hash[:subreddit]}.#{entry_hash[:post_type]}"] += 1
        end
      end

      def error?
        @error != nil
      end      
      
      def each(&block)
        @_store.keys.each do  |k|
          block.call([k, @_store[k]])
        end
      end
      
      def [](key)
        @_store[key]
      end

      def []=(key, val)
        @_store[key]=val
      end

      def keys
        @_store.keys
      end

      def extracted?
        @_extraction_status == true
      end

      def set_status(stat)
        @_extraction_status = (stat == true)
      end
    end

    def initialize
      @userinfo = RedditUserInfo.new   
    end
    
    def user_info(username)
      # Supply Reddit username to retrieve an instance of RedditUserInfo
      pg_queue = ["http://www.reddit.com/user/#{username}/"]

      failure = false
      while !failure and pg_queue.compact.size > 0
        begin
          link = pg_queue.shift
          @dom = get_dom(link)
          @userinfo.aggregate!(extract_userinfo)

          pg_queue << next_page_link
        rescue DomFailure => e
          @userinfo.set_status false
          @userinfo.failed_css = e.message
          failure = true
        rescue OpenURI::HTTPError => e
          @userinfo = nil
          failure = true
        else
          @userinfo.set_status true
        end
      end
      
      @userinfo
    end

    private
    def next_page_link
      # If the user page has a next link return it else return nil (might work for other pages)
      candidate = @dom.xpath('.//span[@class="nextprev"]//a[contains(@rel,"next")]')
      if candidate.count > 0 and /next/.match(candidate.first.text)
        candidate.first.attribute('href').value
      else
        nil
      end
    end

    def extract_userinfo
      # Get user info: DOM parsing happens here
      things = @dom.try_css('.linklisting .thing')

      user_hash = {}
      things.each do |thing|
        thing_type = /comment/.match(thing.attribute('class')) ? :comment : :post
        thing_subreddit = SafeDom.new(thing).try_css('a.subreddit').text
        user_hash[:entries] ||= []
        user_hash[:entries] << {type: thing_type, subreddit: thing_subreddit}
      end
      user_hash.merge({submitted_links: things.count})
    end
  end
end
