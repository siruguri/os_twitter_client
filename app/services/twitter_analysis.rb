module TwitterAnalysis
  def separated_docs_mongo(tweets)
    # For doc analysis purposes, make two lists of original and retweeted tweets

    memo = {tweets_count: 0, orig_tweets_count: 0, all_doc: '', orig_doc: '', retweet_doc: ''}
    tweets.each do |tweet|
      _h = ({'full_text' => tweet.full_text}).
           merge((tweet.retweeted_status === false) ? {} :
                   {'retweeted_status' => {'full_text' => tweet.retweeted_text}
                   }
                )
      h = retrieve_stats _h
      apply_increment h, memo
    end

    memo
  end
  
  def separated_docs(tweets_list)
    # For doc analysis purposes, make two lists of original and retweeted tweets

    memo = {tweets_count: 0, orig_tweets_count: 0, all_doc: '', orig_doc: '', retweet_doc: ''}
    tweets_list.find_each do |tweet|
      h = retrieve_stats tweet.tweet_details
      apply_increment h, memo
    end

    memo
  end

  def apply_increment(h, memo)
    if false === h[:retweeted]
      memo[:orig_doc] += h[:store_mesg] + ' '
      memo[:orig_tweets_count] += 1
    else
      memo[:retweet_doc] +=
        h[:store_mesg] + ' '
    end        
    memo[:tweets_count] += 1
    memo[:all_doc] += h[:store_mesg] + ' '
  end

  def retrieve_stats(tweet_hash)
    h = {}
    if tweet_hash['retweeted_status'].nil?
      h[:retweeted] = false
      h[:store_mesg] = (tweet_hash['text'] || tweet_hash['full_text'])
    else
      h[:retweeted] = true
      retweeted_status_text =
        (tweet_hash['retweeted_status']['text'] || tweet_hash['retweeted_status']['full_text'])
      h[:store_mesg] = retweeted_status_text
    end

    h
  end

  def word_cloud(bio:, document_universe:, tweets: , use_mongo: false)
    # Use a db cache for the text analysis
    word_cloud = {}
    doc_sets = if use_mongo === false
      separated_docs tweets
    else
      separated_docs_mongo tweets
    end

    o_dm = TextStats::DocumentModel.new(doc_sets[:orig_doc], twitter: true)
    a_dm = TextStats::DocumentModel.new(doc_sets[:all_doc], twitter: true)
    r_dm = TextStats::DocumentModel.new(doc_sets[:retweet_doc], twitter: true)
    w_dm = TextStats::DocumentModel.new(bio.webdocs_string, as_html: true)

    # The universes can be nil, that's ok.
    o_dm.universe = document_universe
    a_dm.universe = document_universe
    r_dm.universe = document_universe
    w_dm.universe = document_universe
      
    orig_word_cloud = o_dm.sorted_counts
    all_word_cloud = a_dm.sorted_counts
      
    word_cloud.merge!({orig_word_cloud: orig_word_cloud, tweets_count: doc_sets[:tweets_count],
                       all_word_cloud: all_word_cloud,
                       orig_tweets_count: doc_sets[:orig_tweets_count],
                       
                       orig_word_cloud_filtered: orig_word_cloud.select { |w| remove_entities_and_numbers w },
                       all_word_cloud_filtered: all_word_cloud.select { |w| remove_entities_and_numbers w },
                       retweets_word_cloud: r_dm.sorted_counts.select { |w| remove_entities_and_numbers w },
                       webdocs_word_cloud: w_dm.sorted_counts, orig_word_explanations: o_dm.explanations
                      })
    word_cloud
  end

  private
  def remove_entities_and_numbers(w)
    !(w[0] =~ /\A\d+\Z/ || w[0] =~ /^\#/ || w[0] =~ /^\@/)
#    !(/\A\d+\Z/.match(w[0]) || /^\#/.match(w[0]) || /^\@/.match(w[0]))
  end  
end
