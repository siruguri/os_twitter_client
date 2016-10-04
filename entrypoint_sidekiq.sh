#!/bin/bash
bundle exec sidekiq -q tweets -q mailers -q twitter_fetches -q reanalyses -q scrapers -L log/sidekiq.log
