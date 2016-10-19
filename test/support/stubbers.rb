# user's token
def app_token_headers(app_token = 'abcdefgh')
  {'Accept' => 'application/json', 'Authorization' => /#{app_token}/}
end

# twitter app's token
def single_token_headers
  {'Accept' => 'application/json', 'Authorization' => /cjCezt7cqCpk2c9XgtufSw9zh.*#{Rails.application.secrets.twitter_single_app_access_token}/}
end

def valid_twitter_response(type)
  fixture_file("twitter_#{type}_array.json")
end

def invalid_twitter_response
  {
    'errors': [    {
                     "code": 34,
                    "message": "Sorry, that page does not exist."
                   }]}.to_json
end

def set_net_stubs
  stub_request(:post, "https://api.twitter.com/oauth/request_token").
    with(:headers => {'Accept'=>'*/*', 'Authorization'=>/OAuth oauth_callback=.http%3A%2F%2Ftest.host%2Ftwitter%2Fset_twitter_token., oauth_consumer_key=.cjCezt7cqCpk2c9XgtufSw9zh./}).
    to_return(:status => 200, :body => "a=1&b=2")
  
  stub_request(:post, "https://api.twitter.com/oauth/access_token").
    with(:headers => {'Accept'=>'*/*', 'Authorization'=>/oauth_token."reqsecret", oauth_verifier."oauth_verifier"/}).
    to_return(:status => 200, :body => "")

  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=twitter_handle").
    to_return(status: 200, body: valid_twitter_response(:profile))
  
  stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=nota_twitter_handle").
    to_return(status: 404, body: invalid_twitter_response)
  
  stub_request(:post, "https://api.twitter.com/1.1/statuses/retweet/12341345.json").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:singletweet))

  # Tweets
  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&since_id=567r&trim_user=0&tweet_mode=extended").
    with(headers: single_token_headers).
    to_return(:status => 200, body: valid_twitter_response(:relative_id_tweets))
  
  #statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=bobcostas&trim_user=0
  stub_request(:get, /api.twitter.com.1.1.statuses.user_timeline.json.count=200.exclude_replies=true.include_rts=true.max_id=71209123&screen_name=bobcostas&since_id=9987123/).
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:plaintweets))
  
  stub_request(:get, /api.twitter.com.1.1.statuses.user_timeline.json.count=200.exclude_replies=true.include_rts=true.screen_name=(bobcostas|twitter_handle).trim_user=0.tweet_mode=extended/).
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:plaintweets))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&trim_user=0&tweet_mode=extended").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:plaintweets))

  stub_request(:get, /api.twitter.com.1.1.statuses.user_timeline.json.count=200.*max_id=9918575021211/).
    with(headers: app_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:oldertweets))

  stub_request(:get, /api.twitter.com.1.1.statuses.user_timeline.json.count=200.*max_id=9918575021211/).
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:oldertweets))

  stub_request(:get, /api.twitter.com.1.1.statuses.user_timeline.json.count=200.*max_id=1111911\d+/).
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:empty))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=no_id_here&trim_user=0&tweet_mode=extended").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:oldertweets_noid))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=200&exclude_replies=true&include_rts=true&screen_name=twitter_handle&since_id=9918575028735&trim_user=0&tweet_mode=extended").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:newertweets))

  # Write a tweet
  stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
    with(body: /screen_name=.*handle.*status=my.*tweet/).
    with(headers: app_token_headers).
    to_return(status: 200, body: valid_twitter_response(:singletweet))
  stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
    with(body: /screen_name=.*handle.*status=my.*tweet/).
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:singletweet))
  
  stub_request(:post, "https://api.twitter.com/1.1/statuses/update.json").
    with(:body => {"screen_name"=>"twitter_handle", "status"=>nil},
         :headers => single_token_headers).
    to_return(:status => 200, :body => valid_twitter_response(:tweet_success))

  # Get/fetch one tweet
  stub_request(:get, "https://api.twitter.com/1.1/statuses/show/tweetisthere.json").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:fetch_tweet_available))

  stub_request(:get, "https://api.twitter.com/1.1/statuses/show/tweetistherethathasretweet.json").
    with(headers: single_token_headers).
    to_return(status: 200, body: valid_twitter_response(:fetch_tweet_available_withretw))
              
  # Feed
  stub_request(:get, "https://api.twitter.com/1.1/friends/ids.json?cursor=-1&screen_name=twitter_handle").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:my_feed))
  stub_request(:get, "https://api.twitter.com/1.1/friends/ids.json?cursor=12345&screen_name=twitter_handle").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:my_feed_fresh))

  # Followers
  stub_request(:get, "https://api.twitter.com/1.1/followers/ids.json?count=5000&cursor=-1&screen_name=twitter_handle").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:followers))

  stub_request(:get, "https://api.twitter.com/1.1/followers/ids.json?count=5000&cursor=65065&screen_name=existing_followers_profile").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:followers_with_cursor))

  stub_request(:get, "https://api.twitter.com/1.1/followers/ids.json?count=5000&cursor=-1&screen_name=existing_followers_profile").
    with(headers: single_token_headers).    
    to_return(status: 200, body: valid_twitter_response(:followers_with_cursor_pagination_false))

  # Account settings
  stub_request(:get, "https://api.twitter.com/1.1/account/settings.json").
    with(:headers => app_token_headers("accesstoken-set-in-test")).
    to_return(:status => 200, :body => valid_twitter_response(:account_settings))
  stub_request(:get, "https://api.twitter.com/1.1/account/settings.json").
    with(:headers => app_token_headers("accesstoken-set-in-test-for-new-profile")).
    to_return(:status => 200, :body => valid_twitter_response(:account_settings_for_new_profile))
  
  # Twitter redirects
  stub_request(:get, "https://t.co/MjJ8xAnT").
    with(:headers => {'Accept'=>'*/*',  'Host'=>'t.co'}).
    to_return(:status => 200, :body => "hello")

  stub_request(:get, /https?:..t\.co/).
    with(:headers => {'Accept'=>'*/*',  'Host'=>'t.co'}).
    to_return(:status => 301, :body => "", :headers => {'location' => 'http://redirected.to/1'})

  # Readability
  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=https://medium.com/bolt-blog/who-invests-in-hardware-startups-d1612895a31a").
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, /.*token=testreadabilityapikey.*url=.*dev.witter/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, /.*token=testreadabilityapikey.*url=.*redirected\.to/).
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, body: fixture_file('readability-aldaily-file-1.html'), headers: {'Content-Type' => 'UTF-8'})

  stub_request(:get, "https://www.readability.com/api/content/v1/parser?format=json&token=testreadabilityapikey&url=http://www.reanalysis_1.com/uri1").
    with(:headers => {'Accept'=>'*/*'}).
    to_return(:status => 200, :body => fixture_file('readability-aldaily-file-1.html'), :headers => {'Content-Type' => 'UTF-8'})

  # Aldaily/readability
  stub_request(:get, /.readability.com.*parser.*economist/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-2.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})
  stub_request(:get, /.readability.com.*parser.*spectator/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-1.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})
  stub_request(:get, /.readability.com.*parser.*aeon/).
    to_return(status: 200, body: fixture_file('readability-aldaily-file-3.html'),
              headers: {'Content-Type' => 'application/json; charset=utf-8'})

  stub_request(:get, 'http://www.aldaily.com/').
    to_return(body: fixture_file('aldaily-page.html'))
end
