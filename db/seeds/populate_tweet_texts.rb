TwitterProfile.where('handle is not null').find_each do |tp|
  puts "Running profile #{tp.handle}"
  tweet_count = 0
  idlist = tp.tweets.pluck :tweet_id
  extracted_ids = TweetText.where(tweet_id: {"$in" => idlist}).map { |tt| tt.tweet_id }
  puts "Found #{extracted_ids.count} existing ids"
  tweet_count = 0

  # NOT IN query requires at least one element in array
  extracted_ids = extracted_ids.size == 0 ? [-1] : extracted_ids
  tp.tweets.where('tweet_id not in (?)', extracted_ids).each do |tw|
    tweet_count += 1
    tweet_count = tweet_count % 100
    tt = TweetText.new tweet_id: tw.tweet_id, retweeted_status: (tw.tweet_details['retweeted_status']!=nil),
                       full_text: tw.tweet_details['full_text']
    if tt.retweeted_status
      tt.retweeted_text = tw.tweet_details['retweeted_status']['full_text']
    end
    tt.save

    puts "\t\tsaved #{tw.tweet_id}" if tweet_count%100 == 0    
  end
end

