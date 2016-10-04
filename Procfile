web: bin/rails s
redis: redis-server
worker: bundle exec sidekiq -q twitter_fetches -q mailers -q reanalyses -q scrapers
