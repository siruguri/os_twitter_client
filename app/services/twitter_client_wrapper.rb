class TwitterClientWrapper
  attr_reader :client
  class TwitterClientArgumentException < Exception
  end
  def config
    @config ||= {}
  end
  
  def initialize(opts = {})
    token_rec = opts[:token]
    
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      if token_rec.nil?
        config.access_token    = Rails.application.secrets.twitter_single_app_access_token
        config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
      else
        config.access_token = token_rec.token
        config.access_token_secret = token_rec.secret
      end
    end

    config[:access_token] = opts[:token].present? ? opts[:token].token
                            : Rails.application.secrets.twitter_single_app_access_token
  end

  def perform_now(handle_rec, command, opts)
    response = instance_eval("#{command}(handle_rec, opts)")    
  end
    
  def rate_limited(command = '', &block)
    curr_time = Time.now
    if config[:access_token].nil?
      tok = Rails.application.secrets.twitter_single_app_access_token
    else
      tok = config[:access_token]
    end
      
    ct = TwitterRequestRecord.where('created_at > ? and request_for = ?', curr_time - 1.minute, tok).count

    # Diff commands have different rate limits! Only followers is currently accounted for.
    if command == 'followers' && ct > 0 || ct >= 12
      t = TwitterRequestRecord.last
      t.ran_limit = true
      t.save

      # Enforce max of 12 requests per minute = 180 per 15 min window
      sleep 60 unless Rails.env.test?
    end

    instance_eval(&block) if block_given?
  end

  private
  def extract_user_info(hash)
    hash.nil? ? {} : hash.delete(:user).select { |k, v| [:id, :id_str, :screen_name].include?(k) }
  end
  
  def twitter_regex
    # http://t.co/gboESznVDm
    /https?...t\.co.[^\s]+/
  end

  def save_articles!(article_list, handle)
    # Try to save a list of URLs, if they aren't in the db already
    return if article_list.empty?
    
    existing_urls = WebArticle.where(original_url: article_list).pluck :original_url
    article_list -= existing_urls

    if article_list.size > 0    
      # No callbacks
      article_list = article_list.uniq.select { |u| WebArticle.valid_uri?(u) }

      # This query really eats up a lot of disk space in development
      ActiveRecord::Base.logger.level = 1
      WebArticle.import(
        article_list.map { |new_url| WebArticle.new(original_url: new_url, source: 'twitter', twitter_profile: handle) }
      )
      ActiveRecord::Base.logger.level = 0      
    end
  end
  
  def make_web_article_list(entity_hash)
    # Return list of URLs found in tweets as long as they don't point to twitter.com

    return [] unless entity_hash
    created_articles = []
    entity_hash[:urls].each do |s|
      unless s[:expanded_url].match '.twitter.com'
        created_articles << s[:expanded_url]
      end
    end

    created_articles
  end

  def account_settings!(user_rec)
    # Don't run this method unless we have a user authenticating to Twitter

    return unless user_rec.class == User and config[:access_token].present?

    t = TwitterProfile.new(user: user_rec)
    payload = get(t, :account_settings)
    twitter_id = payload[:data][:id]
    
    if (prev = TwitterProfile.find_by_twitter_id twitter_id).present?
      begin
        prev.user = user_rec
        prev.save!
      rescue ActiveRecord::RecordNotUnique => e
      # User can't claim a profile already claimed by someone else
        rec = TwitterRequestRecord.last
        rec.update_attributes status_message: rec.status_message + ": error: already claimed by #{user_rec.id}"
      end
    else
      t.handle = payload[:data][:screen_name]
      t.save!
    end
  end

  def retweet!(handle_rec, opts)
    payload = post(handle_rec, :retweet, opts)
  end
  
  def tweet!(handle_rec, opts)
    payload = post(handle_rec, :tweet, opts)
  end

  def fetch_status!(opts)
    # Returns a value that denotes whether the requested status was found (1), not found (0) or was
    # blocked (-1). This is used in case the job was started as a follow-up to a tweet that had a quoted
    # tweet.
    
    payload = opts[:tweet_id] ?
                payload = get(nil, :fetch_status, opts) :
                {}

    if payload[:errors] =~ /blocked/
      return -1
    elsif payload[:data]
      d = payload[:data]
      is_retweeted = 
          if d[:retweeted_status].present?
            d[:retweeted_status][:full_text].gsub! twitter_regex, ''
            true
          else
            false
          end
      t = Tweet.new(tweet_details: d, tweet_id: d[:id], mesg: d[:full_text], processed: false,
                    tweeted_at: d[:created_at], is_retweeted: is_retweeted)
      handle = d[:user][:screen_name]
      rec = TwitterProfile.find_or_initialize_by handle: handle
      unless rec.persisted?
        rec.twitter_id = d[:user][:id]
        rec.save
      end
      t.user = rec
      t.save
      
      return 1
    else
      return 0
    end
  end
  
  def fetch_followers!(handle_rec, opts = {})
    opts[:pagination] ||= false
    cursor =
      if opts[:pagination] == true
        if opts[:cursor].blank?
          last_req = TwitterRequestRecord.where(user: handle_rec, request_type: 'follower_ids').order(created_at: :desc).first
          if last_req
            last_req.cursor
          else
            -1
          end
        else
          opts[:cursor]
        end
      else
        -1
      end

    payload = get(handle_rec, :follower_ids, {cursor: cursor, count: 5000})
    if payload[:data] != ''
      ts_id_pairs = TwitterProfile.where(twitter_id: payload[:data][:ids]).pluck(:id, :twitter_id)
      existing_twitter_ids = ts_id_pairs.map { |p| p[1]} 
      ts_id_pairs.each do |pair|
        GraphConnection.find_or_create_by leader_id: handle_rec.id, follower_id: pair[0]
      end

      new_ids = payload[:data][:ids] - existing_twitter_ids

      # Remove stale graph connections, but not if we are paginating...
      if opts[:pagination] == false
        stale_ids = handle_rec.followers.where('twitter_id not in (?)', payload[:data][:ids]).pluck :id
        GraphConnection.where('leader_id = ? and follower_id in (?)', handle_rec.id, stale_ids).map &:delete
      end

      profs = []; conns = []
      new_ids.each do |id|
        t = TwitterProfile.new(twitter_id: id, protected: false)
        profs << t
      end
      TwitterProfile.import profs
      profs.each do |prof|
        conns << GraphConnection.new(leader_id: handle_rec.id, follower_id: prof.id)
      end
      GraphConnection.import conns

      # Pagination
      if opts[:pagination] and payload[:data][:next_cursor] != 0
        # Make sure the new cursor is used, not the old one.
        TwitterFetcherJob.perform_later handle_rec, 'followers',
                                        (opts).merge({cursor: payload[:data][:next_cursor]})
      end
    end
  end

  def fetch_my_friends!(handle_rec)
    unless (last_req = TwitterRequestRecord.where(user: handle_rec, request_type: 'following_ids')).empty?
      cursor = last_req[0].cursor
    else
      cursor = -1
    end
    
    payload = get(handle_rec, :following_ids, {cursor: cursor})
    if payload[:data] != ''
      ts = TwitterProfile.where(twitter_id: payload[:data][:ids])
      friend_ids = handle_rec.friends.pluck :id

      # Remove stale connections
      stale_connections = GraphConnection.
                          joins(:leader).where('follower_id = ? and twitter_profiles.twitter_id not in (?)',
                                               handle_rec.id, payload[:data][:ids])
      stale_connections.map &:delete

      # Add connections that aren't there if the profile already exists
      ts.all.each do |t|
        t.followers << handle_rec unless friend_ids.include? t.id
      end

      # For new ids, create a profile and then add a connection
      new_ids = payload[:data][:ids] - ts.pluck(:twitter_id)
      new_ids.each do |id|
        new_friend = TwitterProfile.create(twitter_id: id, protected: false)
        new_friend.followers << handle_rec
      end
    end
  end
  
  def fetch_profile!(handle_rec)
    # Don't fetch if the data is relatively fresh
    if handle_rec.bio.present? and handle_rec.updated_at > Time.now - 5.minutes
      return
    end
    
    payload = get(handle_rec, :profile, {count: 100})

    if payload[:data] != ''
      handle_rec.handle ||= payload[:data][:screen_name]
      handle_rec.twitter_id ||= payload[:data][:id]
      
      handle_rec.bio = payload[:data][:description]
      handle_rec.location = payload[:data][:location]
      handle_rec.last_tweet = payload[:data][:status]
      unless payload[:data][:status].nil?
        handle_rec.last_tweet_time = DateTime.strptime(payload[:data][:status][:created_at],
                                                       '%a %b %d %H:%M:%S %z %Y')
      end
      handle_rec.member_since = payload[:data][:created_at]
      handle_rec.tweets_count = payload[:data][:statuses_count]
      handle_rec.num_following = payload[:data][:friends_count]
      handle_rec.num_followers = payload[:data][:followers_count]

      handle_rec.save
    end

    payload
  end

  def fetch_tweets!(handle_rec, opts = {})
    # opts[:relative_id] == -1 happens when there are no existing tweets to key to; it also forces new
    # tweets to be retrieved for handle_rec
    limiter = nil
    direction = opts[:direction].try(:to_sym) || :newer
    relative_id = opts[:relative_id]

    return if relative_id.nil?
    
    case direction
    when :newer
      limiter = :since_id
    when :older
      limiter = :max_id
    else
      raise TwitterClientArgumentException.new("#{direction} is not a valid direction (either :newer or :older)")
    end

    # This might be a fetch for a brand new profile (relative_id is -1 for dummy tweet); else, we have a mismatch of
    # parameters so we need this guard
    return if relative_id != -1 && limiter.nil? || relative_id.nil? && limiter.present?
    
    get_hash = (relative_id == -1) ? {} : {limiter: limiter, limit_id: relative_id}

    # Pagination
    if opts[:since_id].present? and direction == :older
      get_hash.merge! ({since_id: opts[:since_id]})
    end
    
    payload = get(handle_rec, :tweets, get_hash)

    # Sometimes, there are no new tweets, or nothing older than what's the newest one provided (which returns 1 obj)
    unless (data = payload[:data]).blank? or (data.size == 1 && direction == :older)
      # This app is designed to create profiles even if only handles are avlbl, but requires Twitter IDs to match
      # tweets to users. So we have to grab the twitter id from the Twitter API response sometimes.

      if handle_rec.twitter_id.present?
        fk = handle_rec.twitter_id
      else
        fk = data.first[:user][:id]
        handle_rec.twitter_id = fk
        handle_rec.save
      end

      new_tweets = []
      all_web_articles = []      
      data.each do |tweet|
        # Scan and store all the URLs into web article models; remove them from the tweets
        is_retweeted = 
          if tweet[:retweeted_status].present?
            tweet[:retweeted_status][:full_text].gsub! twitter_regex, ''
            true
          else
            false
          end

        begin
          orig_user_info = extract_user_info tweet
          retweeted_user_info = extract_user_info tweet[:retweeted_status]
          quoted_user_info = extract_user_info tweet[:quoted_status]
        rescue NoMethodError => e
          Rails.logger.debug "> had trouble with tweet #{tweet}"
        end
        
        if tweet[:quoted_status]
          tweet[:quoted_status][:user] = quoted_user_info
        end
        if tweet[:retweeted_status]
          tweet[:retweeted_status][:user] = retweeted_user_info
        end
        
        new_tweets << Tweet.new(tweet_details: tweet, tweet_id: tweet[:id], mesg: tweet[:full_text], processed: false,
                                tweeted_at: tweet[:created_at], user: handle_rec, is_retweeted: is_retweeted)
        new_tweets.last.mesg.gsub! twitter_regex, ''
        all_web_articles += make_web_article_list tweet[:entities]
      end

      Tweet.import new_tweets, on_duplicate_key_ignore: true
      save_articles! all_web_articles, handle_rec

      # Paginate tweets but don't go crazy trying to fetch tweets for new profiles the first time
      if opts[:pagination] == true
        pass_since = 
          if opts[:since_id].present? && direction == :older
            {since_id: opts[:since_id]}
          elsif direction == :newer && relative_id != -1
            {since_id: relative_id}
          else
            {}
          end
        next_opts = ({pagination: true, direction: 'older', relative_id: new_tweets.last.tweet_id}).merge pass_since
        TwitterFetcherJob.perform_later handle_rec, 'tweets', next_opts
      end
    end

    payload
  end

  def get(handle_rec, command = :profile, opts = {})
    base_request(:get, handle_rec, command, opts)
  end
  def post(handle_rec, command = :profile, opts = {})
    base_request(:post, handle_rec, command, opts)
  end
  
  def base_request(method, handle_rec, command = :profile, opts = {})
    return nil if (handle_rec.nil? and command != :fetch_status) or
      (handle_rec.present? && (
         (handle_rec.user.nil? and command == :account_settings) or
         (handle_rec.handle.nil? and handle_rec.twitter_id.nil? and
          [:follower_ids, :profile, :tweets, :following_ids].include? command)
       ))

    unless handle_rec.nil?
      if handle_rec.handle.present?
        twitter_pk_hash = {screen_name: handle_rec.handle}
      elsif handle_rec.twitter_id.present?
        twitter_pk_hash = {user_id: handle_rec.twitter_id}
      end
    end
    
    case command
    when :fetch_status
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/show/#{opts[:tweet_id]}.json")
    when :retweet
      return nil unless opts[:tweet_id]
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/retweet/#{opts[:tweet_id]}.json")
    when :tweet
      # Allows me to say text instead of status in my code if I want to
      real_opts = opts.clone
      real_opts[:status] ||= real_opts[:text]
      
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/update.json",
                                       twitter_pk_hash.merge(real_opts.select{ |k, v| k == :status}))
    when :account_settings
      req = Twitter::REST::Request.new(@client, method, "/1.1/account/settings.json")
    when :follower_ids
      req = Twitter::REST::Request.new(@client, method, "/1.1/followers/ids.json",
                                       twitter_pk_hash.merge(opts.select { |k, v| k == :cursor || k == :count}))
    when :following_ids
      req = Twitter::REST::Request.new(@client, method, "/1.1/friends/ids.json",
                                       twitter_pk_hash.merge(opts.select { |k, v| k == :cursor }))
    when :profile
      req = Twitter::REST::Request.new(@client, method, "/1.1/users/show.json", twitter_pk_hash)
    when :tweets
      whitelist = [:since_id, :tweet_mode]
      addl_opts = opts[:limiter] ? ({opts[:limiter] => opts[:limit_id]}) : {}
      addl_opts.merge!(
        opts.select { |k, v| whitelist.include?(k) }
      )

      tweets_hash = {
        include_rts: true, trim_user: 0,  exclude_replies: true, count: 200, tweet_mode: 'extended'
      }.merge(twitter_pk_hash).merge(addl_opts)
      req = Twitter::REST::Request.new(@client, method, "/1.1/statuses/user_timeline.json",
                                       tweets_hash)
    end

    status = true
    cursor = prev_cursor = -1
    errors = {}
    body = ''
    
    begin
      response = req.perform
    rescue Twitter::Error, Twitter::Error::NotFound => e
      errors = {errors: "handle db id: #{handle_rec&.id}, error: #{e.message}"}
    else
      body =
        if response.is_a? Hash and response.keys.size == 2 and response.keys.include?(:headers)
          # At one point I was mucking with the Twitter gem to force it to return the actual HTTP
          # response, so I could look at its headers
          response[:body]
        else
          response
        end
      
      case command
      when :tweets
        cursor = body.blank? ? opts[:limit_id] : body.last[:id]
      when :follower_ids
        cursor = body[:next_cursor]
        prev_cursor = body[:previous_cursor]
      end
    end

    c = TwitterRequestRecord.create request_type: command, prev_cursor: prev_cursor,
                                    cursor: cursor, status: errors.empty?,
                                    status_message: errors.empty? ? '' : errors[:errors],
                                    request_for: config[:access_token],
                                    handle: (command == :account_settings ? body[:screen_name] : handle_rec&.handle)

    if /not authorized/i.match c.status_message
      handle_rec.update_attributes protected: true
    end
    
    {data: body}.merge errors
  end
end
