class TwittersController < ApplicationController
  include TwitterAnalysis
  before_action :set_handle_or_return, only: [:twitter_call, :analyze, :feed]
  before_action :authenticate_user!, only: [:schedule]

  def schedule
    # Can only schedule for connected accounts.
    if current_user.twitter_profile.nil?
      flash[:notice] = 'Your account doesn\'t have a handle yet. Please set one.'
      redirect_to twitter_input_handle_path and return
    end
    
    if request.request_method == 'GET'
      render :schedule
    elsif request.request_method == 'POST'
      if message_list = construct_messages
        @app_token = set_app_tokens
        DripTweetJob.perform_later current_user.twitter_profile, message_list, token: @app_token
      end
    else
      redirect_to new_user_session_path
    end
  end
  
  def input_handle
    set_input_handle_path_vars
  end

  def index
    @handles_by_tweets = Tweet.joins(:user).group('twitter_profiles.handle').count

    # Filter down if there's a filter parameter
    leader=nil
    if params[:followers_of]
      leader = TwitterProfile.find_by_handle params[:followers_of]
    end
    if !leader and current_user and current_user.twitter_profile and current_user.twitter_profile.handle
      leader = current_user.twitter_profile
    end
    if leader
      @profiles_list = leader.followers
    else
      @profiles_list = TwitterProfile.where('handle is not null')
    end

    @profiles_list = @profiles_list.joins(:profile_stat).includes(:profile_stat).where('profile_stats.stats_hash_v2 != ?', '{}')
    @profiles_list_sorts = {tweets_count: @profiles_list.order(tweets_count: :desc),
                            tweets_retrieved: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'total_tweets\')::integer desc'),
                            retweets_collected: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'retweet_aggregate\')::integer desc'),
                            retweeted_avg: @profiles_list.order('(profile_stats.stats_hash_v2 ->> \'retweeted_avg\')::float desc'),
                            last_known_tweet_time: @profiles_list.order(last_tweet_time: :desc)
                           }
  end

  def authorize_twitter
    if current_user
      client = OAuth::Consumer.new(
        Rails.application.secrets.twitter_consumer_key,
        Rails.application.secrets.twitter_consumer_secret,
        site: 'https://api.twitter.com'
      )

      callback_str = twitter_set_twitter_token_url
      request_token = client.get_request_token(oauth_callback: callback_str)

      o = OauthTokenHash.create(source: 'twitter', user: current_user, request_token: request_token.to_yaml)
      if Rails.env.test?
        redirect_to 'test.twitter.com/authorize'
      else
        redirect_to request_token.authorize_url
      end
    else
      redirect_to new_user_session_path, notice: 'Need to be signed in locally'
    end      
  end
  
  def set_twitter_token
    if current_user
      if params[:oauth_token].present? and
        params[:oauth_verifier].present?
        latest_tokenhash = current_user.latest_token_hash('twitter')

        req_token = YAML.load(latest_tokenhash.request_token)
        client = OAuth::Consumer.new(
          Rails.application.secrets.twitter_consumer_key,
          Rails.application.secrets.twitter_consumer_secret,
          site: 'https://api.twitter.com'
        )

        acc_token = client.get_access_token(req_token, oauth_verifier: params[:oauth_verifier])
        # This token will not expire - https://dev.twitter.com/oauth/overview/faq (9/9/16)
        latest_tokenhash.update_attributes(token: acc_token.token, secret: acc_token.secret)

        x = current_user
        TwitterClientWrapper.new(token: latest_tokenhash).rate_limited do
          account_settings! x
        end

        @remote_id = x.twitter_profile.handle
      else
        render nothing: true
      end
    else
      render nothing: true
    end
  end

  def batch_call
    @app_token = set_app_tokens
    
    if params["no-tweet-profiles"].present?
      no_tweets_profiles_query.all.each do |profile|
        bio profile
        tweets profile
      end
    end
    redirect_to twitter_input_handle_path
  end
  
  def twitter_call
    if params[:commit]
      @app_token = set_app_tokens

      case params[:commit].downcase
      when /refresh.*feed/i
        if current_user
          # Can't refresh feed if no one's logged in
          @notice = TwitterManagement::Feed.refresh_feed(@bio, @app_token).join '; '
        end
      when /whom.*follow/i
        my_friends      
      when /populate.*followers/
        followers
      when /get.*bio/
        bio @bio
      when /get.*older tweets/
        # Let's get the bio too, if we never did, when asking for tweets
        bio @bio if !@bio.member_since.present?
        tweets(@bio, direction: 'older')
      when /get newer tweets/
        tweets(@bio, direction: 'newer')
      end

      unless @notice.blank?
        @notice = "Request returned: #{@notice}"
      end
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to twitter_input_handle_path
  end

  def feed
    unless params[:refresh_now] == '1' or current_user.nil?
      @time_to_wait = (Time.now - 24.hours) - (Tweet.top_of_feed(current_user.twitter_profile) || DateTime.now - 1.year)

      # how long before the next refresh? Might be more efficient to do this on the client, in JS
      if @time_to_wait < 0
        t = -1 * @time_to_wait
        @hrs = (t / 3600).floor
        @mins = (60 * ((t / 3600) - @hrs)).floor
        @secs = (t - (3600 * @hrs + 60 * @mins)).floor
      end
    else
      @time_to_wait = 0
    end

    page =
      if current_user
        bkmk_key = "#{current_user.email}.twitter.bookmark"
        bkmk = Config.find_by_config_key(bkmk_key)&.config_value
        params[:page]&.to_i || bkmk&.to_i || 1
      else
        1
      end
    
    @feed_list = current_user&.twitter_profile ?
                   Tweet.latest_by_friends(current_user.twitter_profile).paginate(page: page, per_page: 10) :
                   []
    if @feed_list.size > 0 && (params[:page]&.to_i == 1 || bkmk.nil? || bkmk.to_i < page)
      c = Config.find_or_create_by(config_key: bkmk_key)
      c.update_attributes config_value: page
    end
  end
  
  def analyze
    @latest_tweets = Tweet.where(user: @bio).order(tweeted_at: :desc)

    newest_tweet_enter_date = (lt = @latest_tweets&.first) ? lt.tweeted_at : nil
    @been_a_while = lt.nil? || ((DateTime.now - 24.hours) > newest_tweet_enter_date)
    
    unless @latest_tweets.count == 0
      @universe_size = DocumentUniverse.count
      @word_cloud = word_cloud
    end

    @g_set_title = @bio.handle
  end

  private
  def set_input_handle_path_vars
    @no_tweet_profiles = no_tweets_profiles_query.count
    if current_user&.latest_token_hash
      @user_has_profile = current_user.twitter_profile.present?
      # BUG: this handle might not be set by the account_settings job before this page is refreshed.
      @user_handle = current_user.twitter_profile&.handle
    end
  end
  
  def no_tweets_profiles_query
    TwitterProfile.includes(:tweets).
      joins('left OUTER JOIN tweets ON tweets.twitter_id = twitter_profiles.twitter_id').where('tweets.id is null and protected =? and (twitter_profiles.created_at > ? or member_since > ?)', false, DateTime.now - 7.days, DateTime.now - 6.months)
  end
  
  def set_handle_or_return
    # Params overrides other behavior
    if params[:handle].nil? 
      (redirect_to new_user_session_path and return) if (@bio = current_user&.twitter_profile).nil?
    end

    # Set bio if it didn't come from the logged in user above.
    @bio ||= TwitterProfile.where('lower(handle) = ?', "#{params[:handle].downcase}").first
    (redirect_to new_user_session_path and return) if @bio.nil?

    if @bio.twitter_id.present?
      @identifier_fk_hash = {twitter_id: @bio.twitter_id}
      @identifier = @bio.twitter_id
    else
      @identifier_fk_hash = {handle: @bio.handle}
      @identifier = @bio.handle
    end

    true
  end
  
  def my_friends
    TwitterFetcherJob.perform_later @bio, 'my_friends', token: @app_token
  end
  
  def followers
    TwitterFetcherJob.perform_later @bio, 'followers', token: @app_token
  end
  def bio(t)
    TwitterFetcherJob.perform_later t, 'bio', token: @app_token
  end
  def tweets(t, opts = {})
    TwitterFetcherJob.perform_later t, 'tweets', ({token: @app_token}.merge(opts))
  end

  def word_cloud
    # Use a db cache for the text analysis
    if @bio.word_cloud.empty? or params[:word_cloud] == '1'
      @word_cloud = {}
      doc_sets = separated_docs @latest_tweets.all

      o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
      a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
      r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
      w_dm = TextStats::DocumentModel.new(crawled_web_documents(@bio), as_html: true)
      
      if @universe_size > 0
        du = DocumentUniverse.last.universe
        o_dm.universe = du
        a_dm.universe = du
        r_dm.universe = du
        w_dm.universe = du
      end
      
      orig_word_cloud = o_dm.sorted_counts
      all_word_cloud = a_dm.sorted_counts
      
      @word_cloud.merge!({orig_word_cloud: orig_word_cloud, tweets_count: doc_sets[:tweets_count],
                          orig_tweets_count: doc_sets[:orig_tweets_count],
                          orig_word_cloud_filtered: orig_word_cloud.select { |w| remove_entities_and_numbers w },
                          all_word_cloud: all_word_cloud,
                          all_word_cloud_filtered: all_word_cloud.select { |w| remove_entities_and_numbers w },
                          retweets_word_cloud: r_dm.sorted_counts.select { |w| remove_entities_and_numbers w },
                          webdocs_word_cloud: w_dm.sorted_counts, orig_word_explanations: o_dm.explanations
                         })
      @bio.word_cloud = @word_cloud
      @bio.save
    end

    @bio.word_cloud
  end
    
  def set_app_tokens
    current_user ? current_user.latest_token_hash('twitter') : nil
  end

  def crawled_web_documents(profile)
    @word_cloud[:webdocs_count] = 0
    WebArticle.where('web_articles.body is not null and twitter_profile_id = ?', profile.id).all.map do |article|
      @word_cloud[:webdocs_count] += 1
      article.body
    end.join ' '
  end

  def construct_messages
    # return nil if params is incorrect

    ret = nil
    if params[:uri] and (list = params.dig(:twitter_schedule, :messages))
      ret = list.map { |msg| "#{msg} #{params[:uri]}" }
    end

    ret
  end

  def remove_entities_and_numbers(w)
    !(/\A\d+\Z/.match(w[0]) || /^\#/.match(w[0]) || /^\@/.match(w[0]))
  end
end
