class TwitterChannelPoster < ActiveJob::Base
  queue_as :twitter_channel_posts

  def perform(channel_post)
    @twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key    = Rails.application.secrets.twitter_consumer_key
      config.consumer_secret = Rails.application.secrets.twitter_consumer_secret
      config.access_token    = Rails.application.secrets.twitter_single_app_access_token
      config.access_token_secret = Rails.application.secrets.twitter_single_app_access_token_secret
    end

    tweet = channel_post.message + " https://#{ENV['RAILS_REDIRECT_HOSTNAME']}#{ENV['RAILS_REDIRECT_PORT']?':'+ENV['RAILS_REDIRECT_PORT']:''}#{ENV['RAILS_REDIRECT_PATH_PREFIX']}/r/#{channel_post.redirect_maps[0].src}"

    a=@twitter_client.update tweet
    channel_post.total_post_count +=1
    channel_post.media_records.build({channel_id: a.id, channel_name: 'twitter'})

    channel_post.save
  end
end
