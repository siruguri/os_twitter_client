class TwitterFetcherJob < ActiveJob::Base
  queue_as :twitter_fetches

  def perform(handle_rec, command='bio', opts = {})
    # Some commands are wrappers for other commands
    if command == 'follower_bios'
      handle_rec.followers.each do |f|
        TwitterFetcherJob.perform_later f, 'bio', opts
      end
    else
      TwitterClientWrapper.new(opts).rate_limited(command) do
        case command.to_sym
        when :search
          search! opts
        when :fetch_status
          fetch_status! opts
        when :retweet
          retweet! handle_rec, opts
          r = RetweetRecord.new tweet_id: opts[:tweet_id], user_id: handle_rec.user.id
          r.save
        when :tweet
          tweet! handle_rec, opts
        when :followers
          # Will not paginate by default; pick cursor as a whitelisted option
          fetch_followers! handle_rec, cursor: opts[:cursor], pagination: (opts[:pagination] || false),
                           token: opts[:token]
        when :my_friends
          fetch_my_friends! handle_rec
        when :bio
          fetch_profile! handle_rec
        when :tweets
          if opts[:relative_id].nil?
            # The default behavior is to get the timeline that's more recent than the most recent tweet or that's older
            # than the oldest know tweets.
            t = if opts[:direction].try(:to_sym) == :older
                  handle_rec.tweets.oldest
                else
                  handle_rec.tweets.newest
                end
            opts[:relative_id] = t&.tweet_id || -1
          end
          
          fetch_tweets! handle_rec, opts

          # This might be a fetch on someone's feed who was reading it and had a bookmark. Trample it!
          if (bkmk = opts[:refresh_bookmark]) &&
             (c = Config.find_by_config_key bkmk)
            c.update_attributes config_value: '1'
          end
        end
      end
    end
  end
end
