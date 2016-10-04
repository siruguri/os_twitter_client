redis_options_hash = { url: "redis://#{ENV['REDIS_HOST']}:6379/0", namespace: "os_twitter_client" }

Sidekiq.configure_server do |config|
  config.redis = redis_options_hash
end

Sidekiq.configure_client do |config|
  config.redis = redis_options_hash
end
