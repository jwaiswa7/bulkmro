source 'https://rubygems.org'
git_source(:github) {|repo| "https://github.com/#{repo}.git"}

# ruby '2.5.3'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'

# Use pg as the database for Active Record
gem 'pg'

# Use Puma as the app server
gem 'puma', '~> 3.11'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Avoid polling
gem 'wdm', '>= 0.1.0' if Gem.win_platform?

# Cron for Rails
gem 'clockwork'

# Slack Ruby lib
gem 'slack-ruby-client'

# Easy ENV-like variables
gem 'config'

# Full text search in PostgreSQL
gem 'pg_search'

# Log of changes for models
gem 'paper_trail'

# Hash ids in url
gem 'hashid-rails', '~> 1.0'

# Access control using policies
gem 'pundit'

# Authentication
gem 'devise'

# Nested forms made easy
gem 'nested_form_fields'

# Forms made easy
gem 'simple_form'

# Generate fake data
gem 'faker'

# Paginate ActiveRecord
gem 'kaminari'

# Handles self-referencing tables
gem 'closure_tree'

# Generate two-factor codes
gem 'rotp'

# Send text messages
gem 'twilio-ruby', '~> 5.11.2'

# Send text messages
gem 'msg91ruby'

# Validate phone numbers
gem 'phony_rails'

# Use Microsoft Azure for file storage
gem 'azure-storage', require: false
gem 'azure-storage-blob'
# Parse xls files
gem 'spreadsheet', require: false

# Parse XLSX files
gem 'simple_xlsx_reader'

# Render XLSX files
gem 'axlsx', '3.0.0.pre'
gem 'axlsx_rails', '0.5.2'
gem 'rubyzip', '~> 1.2'

# Validate file uploads
gem 'file_validators'

# Http requests made easy
gem 'httparty'

# Render html as pdf
gem 'wicked_pdf'

# Send transactional emails
gem 'sendgrid-ruby'

# Validate dates in ActiveRecord
gem 'validates_timeliness', '~> 5.0.0.alpha3'

# Custom error pages
gem 'gaffe'

# Easy country selection
gem 'country_select'

# Two-factor authentication for Devise
gem 'two_factor_authentication'

# Dump database into file
gem 'seed_dump'

# Better nested forms
gem 'cocoon'

# Rails routes in JavaScript
gem 'js-routes'

# Deep clone ActiveRecord objects
gem 'deep_cloneable', '~> 2.3.2'

# Remote objects
gem 'activeresource'

# OJ for Parsing JSON
gem 'oj'

# Serialize models
gem 'fast_jsonapi'

# Omniauth Google
gem 'omniauth-google-oauth2'

# Slack real-time requirement
gem 'async-websocket'

# Elasticsearch
gem 'chewy'

# Sentry.io error monitoring
gem 'sentry-raven'

# Easy group by queries
gem 'hightop'
gem 'groupdate'

# Background tasks
gem 'sidekiq'

# NET SCP for sending files to SAP
gem 'net-scp'

# Foreign exchange rate
gem 'money-open-exchange-rates'

# Better rails console readability
gem 'awesome_print'

# Used memcached for caching
gem 'dalli'
gem 'memcachier'

# Heroku platform API
gem 'platform-api'

gem 'pry'
# Google Cloud API
gem 'googleauth'
gem 'google-api-client', '~> 0.11'

gem 'parser'
gem 'unparser'
gem 'mini_magick'

#This gem allows you to write static Rails views and partials using the Markdown syntax. No more editing prose in HTML!
gem 'markdown-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'maily'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Preview emails instead of sending them
  gem 'letter_opener'

end

group :test do
  # Adds support for Capybara system testing and selenium driver
  # gem 'capybara', '>= 2.15', '< 4.0'
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
end

group :production do
  gem 'bonsai-elasticsearch-rails', '~> 7'
end

group :staging do
  gem 'bonsai-elasticsearch-rails', '~> 7'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# For JS build tooling anf ES6 support
gem 'webpacker', '~> 3.5'

# For Notification bot
gem 'slack-ruby-bot'

# For charts
gem 'chartjs-ror'

#For online payments with Razorpay
gem 'razorpay'

# Wit.ai
gem 'wit'