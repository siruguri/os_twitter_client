TwitterProfile.find_each do |tp|
  puts "Running profile #{tp.handle}"
  tweet_count = 0
  tp.tweets.find_each do |tw|
    puts "\tRunning tweet batch" if tweet_count % 100 == 0
    tweet_count += 1
    tweet_count = tweet_count % 100
    
    unless TweetText.where(tweet_id: tw.tweet_id).count > 0
      puts "\t\tsaved #{tw.tweet_id}" if tweet_count%100 == 0
      tt = TweetText.new tweet_id: tw.tweet_id, retweeted_status: (tw.tweet_details['retweeted_status']!=nil),
                         full_text: tw.tweet_details['full_text']
      if tt.retweeted_status
        tt.retweeted_text = tw.tweet_details['retweeted_status']['full_text']
      end
      tt.save
    end
  end
end

