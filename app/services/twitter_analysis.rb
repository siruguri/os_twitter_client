module TwitterAnalysis
  def separated_docs(tweets_list)
    # For doc analysis purposes, make two lists of original and retweeted tweets
    tweets_list.inject({tweets_count: 0, orig_tweets_count: 0, all_doc: '', orig_doc: '', retweet_doc: ''}) do |memo, tweet|
      # Store original tweets in one key...
      if tweet.tweet_details['retweeted_status'].nil?
        memo[:orig_doc] = "#{memo[:orig_doc]} #{tweet.mesg}"
        store_mesg = tweet.mesg
        memo[:orig_tweets_count] += 1
      else
        memo[:retweet_doc] = "#{memo[:retweet_doc]} #{tweet.tweet_details['retweeted_status']['text']}"
        store_mesg = tweet.tweet_details['retweeted_status']['text']
      end

      # And all tweets in another
      memo[:all_doc] = "#{memo[:all_doc]} #{store_mesg}"
      memo[:tweets_count] += 1
      memo
    end
  end
end
