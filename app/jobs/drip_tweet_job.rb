class DripTweetJob < ActiveJob::Base
  queue_as :tweets
  
  def perform(handle_rec, tweet_list, opts = {})
    client = TwitterClientWrapper.new(token: opts[:token])
    mesg = tweet_list.shift
    client.rate_limited do
      tweet! handle_rec, {status: mesg}
    end

    if tweet_list.size > 0
      DripTweetJob.set(wait: 10.minutes).perform_later handle_rec, tweet_list
    end
  end
end
