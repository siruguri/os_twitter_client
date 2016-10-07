source 'https://rubygems.org'
ruby '2.3.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', ">=5.0"
# Use SCSS for stylesheets
gem 'sass-rails', ">=5.0"
gem 'jquery-ui-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
gem 'underscore-rails'

gem 'activerecord-import', git: 'https://github.com/zdennis/activerecord-import.git', tag: 'v0.15.0'

# No issue found that references possible bug in update to 3, possibly interacting with something else.
gem 'sprockets'
gem 'thin'

gem 'devise'
gem 'js-routes'
gem 'will_paginate'
gem 'mongoid',  git: 'https://github.com/mongodb/mongoid', tag: 'v6.0.0'
gem 'pg'

group :production do
  gem 'newrelic_rpm'
  gem 'execjs'
end

# quiet_assets? https://rossta.net/blog/quiet-assets-in-rails-5.html
gem 'dotenv'

# Everybody gotta have some Bootstrap!
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'rails-backbone'

gem 'haml'
gem 'json'

gem 'redis-namespace'
gem 'sidekiq'
# Required for sidekiq monitoring
gem 'sinatra', :require => nil

# Reddit scraping
gem 'nokogiri'
gem 'twitter'
gem 'oauth'

gem 'web-console', ">3.0", group: :development
gem 'ruby-prof'

group :development, :test do
  # Use sqlite3 as the database for Active Record in dev and test envs
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'rails-controller-testing'
end

group :test do
  gem 'mongoid-fixture_set', git: 'https://github.com/wittawasw/mongoid-fixture_set', branch: 'rails5'
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'mocha'
  gem 'simplecov'
  gem 'webmock'
  gem 'minitest-spec-rails'
  gem 'minitest-rails-capybara'
end
