require 'test_helper'
require 'webmock/minitest'

class TwitterChannelPosterTest < ActiveSupport::TestCase
  def setup
    stub_request(:post, "https://#{Rails.application.secrets.twitter_consumer_key}:#{Rails.application.secrets.twitter_consumer_secret}@api.twitter.com/oauth2/token").
      with(:body => "grant_type=client_credentials",
           :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded; charset=UTF-8', 'User-Agent'=>'TwitterRubyGem/5.14.0'}).
      to_return(:status => 200, :body => "{\"token_type\": \"bearer\", \"access_token\":\"myaccesstoken\"}", :headers => {})

    stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
      with(:body => /status=/).
      to_return(:status => 200, :body => "{\"id\": 1}", :headers => {})
  end

  test 'job posts to Twitter correctly' do
    c=ChannelPost.new(url: 'http://a.com/b', message: 'send this message')
    c.save
    TwitterChannelPoster.perform_now c

    assert_equal 1, c.total_post_count
    assert_equal 'twitter', c.media_records[0].channel_name
  end
end
