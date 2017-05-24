class TweetTextCreateJob < ActiveJob::Base
  # To create the mongo records given the tweet PG records
  queue_as :reanalyses 
  
  def perform(rec_list)
    rec_list.each do |rec|
      t = TweetText.new(tweet_id: rec.tweet_id,
                        full_text: rec.mesg,
                        retweeted_text: rec.tweet_details.dig('retweeted_status', 'full_text'),
                        retweeted_status: !rec.tweet_details.dig('retweeted_status').nil?)
      t.save
    end
  end
end
