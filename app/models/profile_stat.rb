class ProfileStat < ActiveRecord::Base
  belongs_to :twitter_profile

  def self.build_cache(twitter_id: nil)
    @update_recs = []
    @new_recs = []

    # Scheme to make stats update optimized
    profile_data =
      if twitter_id.nil?
        TwitterProfile.pluck(:id, :twitter_id, :num_following)
      else
        TwitterProfile.where(twitter_id: twitter_id).pluck(:id, :twitter_id, :num_following)
      end 

    profile_data.each_slice(500) do |twitter_profile_array|
      # We take 100 profiles at a time, so that we can retrieve db records efficiently.
      twitter_id_array = twitter_profile_array.map { |set| set[1] }
      id_array = twitter_profile_array.map { |set| set[0] }
      
      unproc_tweets = Tweet.where(processed: false, twitter_id: twitter_id_array).order(tweeted_at: :desc)
      stats_recs_hash = ProfileStat.where(twitter_profile_id: id_array).all.group_by do |ps|
        ps.twitter_profile_id
      end
      unproc_tweets.group_by { |tweet| tweet.twitter_id }.each do |twitter_id, tweets|
        # And update the recs hash for each profile in that list, which happens in memory
        profile_data = twitter_profile_array.select { |rec| rec[1] == twitter_id }.first

        # Because stats_rec_hash is simply a pointer, we can update its components efficiently.
        stats_rec = get_stat_rec stats_recs_hash, profile_data[0]
        if stats_rec.persisted?
          @update_recs << stats_rec
        else
          @new_recs << stats_rec
        end

        update_followers profile_data, stats_rec, save_later: true
        update_tweet_counts profile_data, tweets, stats_rec, save_later: true
        Tweet.where('tweet_id in (?)', tweets.pluck(:tweet_id)).update_all processed: true
      end
    end

    if @new_recs.size > 0
      ProfileStat.import @new_recs
    end
    if @update_recs.size > 0
      ProfileStat.import(@update_recs, on_duplicate_key_update: { conflict_target: :id, columns: [:stats_hash_v2]})
    end
  end

  private
  def self.get_stat_rec(existing_stat_recs, db_id)
    if existing_stat_recs[db_id]
      existing_stat_recs[db_id].first
    else
      stat_rec = ProfileStat.new twitter_profile_id: db_id, stats_hash_v2: {}

      stat_rec.stats_hash_v2['total_tweets'] = 0
      stat_rec.stats_hash_v2['retweet_aggregate'] = 0
      stat_rec.stats_hash_v2['retweeted_mesgs'] = 0
      stat_rec.stats_hash_v2['follower_count'] = 0
      existing_stat_recs[db_id] = stat_rec

      stat_rec
    end
  end
  
  def self.update_followers(profile_data, stat_rec, opts = {})
    opts[:save_later] ||= false
    twitter_id = profile_data[1]

    unless stat_rec.stats_hash_v2['follower_count'] == profile_data[2]
      stat_rec.stats_hash_v2['follower_count'] = profile_data[2]
      stat_rec.save unless opts[:save_later]
    end
  end
  
  def self.update_tweet_counts(twitter_id, tweets, stat_rec, opts = {})
    # Count total tweets in db, and total retweet count across all these
    # tweets - the second arg is in descending order of tweeted_at time

    opts[:save_later] ||= false
    if stat_rec.most_recent_tweet_at && tweets.first.tweeted_at > stat_rec.most_recent_tweet_at
      stat_rec.most_recent_tweet_at = tweets.first.tweeted_at
    end
    
    if stat_rec.most_old_tweet_at && tweets.last.tweeted_at < stat_rec.most_old_tweet_at
      stat_rec.most_old_tweet_at = tweets.last.tweeted_at
    end
    
    retweet_agg = retweeted_mesgs = 0

    tweets.each do |tweet_rec|
      # If this is an original message that has been re-tweeted, we want to know!
      tweet_deets = tweet_rec.tweet_details
      if tweet_deets['retweeted_status'].nil? && tweet_deets['retweet_count'].try(:>, 0) == true        
        retweet_agg += tweet_deets['retweet_count']
        retweeted_mesgs += 1
      end
    end

    new_hash = stat_rec.stats_hash_v2
    ['total_tweets', 'retweet_aggregate', 'retweeted_mesgs', 'retweeted_avg'].each do |k|
      new_hash[k] ||= 0
    end
    
    new_hash['total_tweets'] += tweets.count
    new_hash['retweet_aggregate'] += retweet_agg
    new_hash['retweeted_mesgs'] += retweeted_mesgs
    new_hash['retweeted_avg'] = retweeted_mesgs == 0 ? 0 : (retweet_agg / retweeted_mesgs)
    
    # This is necessary to force serialization of the JSONB column. Setting values of individual keys
    # doesn't cause that to happen.
    stat_rec.stats_hash_v2 = new_hash
    stat_rec.save unless opts[:save_later]
  end
end
