module Ajax
  class Actions
    def self.perform(idx, opts = {})
      executed = false
      case idx
      when 1
        list = []
        if t = opts[:user]&.twitter_profile
          list = TwitterManagement::Feed.refresh_feed(t).join '; '
          Response.update list
          executed = true
        end
      when 2
        if opts[:user].present? and opts[:user].is_a?(User)
          retweet_data = JSON.parse(opts[:data][0])
          if retweet_data['quote'].present?
            #http://stackoverflow.com/questions/29680965/how-do-i-properly-retweet-with-a-comment-via-twitters-api
            twt = Tweet.find_by_tweet_id(retweet_data['tweet_id'])
            handle = twt.user.handle
            mesg = retweet_data['quote'] + " https://twitter.com/#{handle}/status/#{retweet_data['tweet_id']}"
            j = TwitterFetcherJob.perform_later opts[:user]&.twitter_profile, 'tweet',
                                                {text: mesg, token: opts[:user].latest_token_hash}
          else
            j = TwitterFetcherJob.perform_later opts[:user]&.twitter_profile, 'retweet',
                                                {tweet_id: retweet_data['tweet_id'],
                                                 token: opts[:user].latest_token_hash}
          end
          Response.update "retweet scheduled"
          executed = true
        end
      when 3
        if opts[:user].present? and opts[:user].is_a?(User)
          tweet_id_list = JSON.parse(opts[:data][0]).map { |s| s.to_i }
          retweets = RetweetRecord.where(user_id: opts[:user].id).in(tweet_id: tweet_id_list).map { |r| r.tweet_id }
          Response.update retweets
          executed = true
        end
      end

      executed
    end    

    def self.valid_ids
      [1, 2, 3]
    end

    def self.last_known_response
      Response.last_known_response
    end
  end
end
