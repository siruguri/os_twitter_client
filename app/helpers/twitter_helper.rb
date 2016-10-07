module TwitterHelper
  def number_of_tweets_message(profile)
    # This is only ever called for profiles that have stats calculated
    stat = profile.profile_stat
    "#{sprintf("%0.2f", stat.stats_hash_v2['retweeted_avg'])} / " +
      " #{stat.stats_hash_v2['retweet_aggregate']}"
  end
  
  def nice_date(dt)
    dt.strftime "%Y-%m-%d %H:%M"
  end
  
  def word_display(w, divisor)
    "#{w[0]}: #{sprintf("%0.3g", w[1]*100/divisor)} [#{sprintf("%0.3g", (@word_cloud[:orig_word_explanations][w[0]+'.tf']||1)*100)}, #{sprintf("%0.3g", (@word_cloud[:orig_word_explanations][w[0]+'.idf']||1)*100)}]"
  end
  
  def twitter_cloud_box_partial(type, title_text)
    (word_list, divisor) =
      case type
      when :webdocs
        [@word_cloud[:webdocs_word_cloud], @bio.crawled_web_documents.count]
      when :retweets
        [@word_cloud[:retweets_word_cloud], @word_cloud[:tweets_count] - @word_cloud[:orig_tweets_count]]
      when :all
        [@word_cloud[:all_word_cloud_filtered], @word_cloud[:tweets_count]]
      when :orig
        [@word_cloud[:orig_word_cloud_filtered], @word_cloud[:orig_tweets_count]]
      when :hashtags
        [(@word_cloud[:orig_word_cloud] + @word_cloud[:all_word_cloud]).select { |w| /^\#/.match(w[0])}.sort_by { |p| -p[1]}.uniq { |i| i[0] }, @word_cloud[:tweets_count]]
      when :handles
        [(@word_cloud[:orig_word_cloud] + @word_cloud[:all_word_cloud]).select { |w| /^\@/.match(w[0]) && w[0] != '@'}.sort_by { |p| -p[1]}.uniq { |i| i[0] }, @word_cloud[:tweets_count]]
      end

    render partial: 'twitter_cloud_box',
           locals: {word_list: word_list.slice(0..25),
                    list_type_title: title_text, divisor: divisor}
  end

  def better_urls(tweet)
    if tweet.is_a? Tweet
      mesg_str = tweet.mesg
      entities_hash = tweet.tweet_details['entities']
    else
      # This changed in the Twitter API and I modified it in my code in Sep '16
      mesg_str = tweet['full_text'] || tweet['text']
      entities_hash = tweet['entities']
    end
    
    # Remove t.co urls, and replace with the full extended urls
    str = mesg_str.gsub(/http.?:\/\/t\.co\/[^\s]+/, '')
    unless entities_hash['urls'].nil?
      str += entities_hash['urls'].map do |u|
        "(<a href='#{u['expanded_url']}'>#{u['expanded_url']}</a>)"
      end.join ' '
    end
    
    str.html_safe
  end

  def better_time(tweet)
    tweet.tweeted_at.strftime '%m %d %H:%M'
  end

  def tweet_text(tweet)
    tweet.mesg
  end
end
