web: bundle exec puma -C config/puma.rb
slack_bot: ruby slack_bot.rb
worker: bundle exec sidekiq
clock: bundle exec clockwork clock.rb
rake tmp:cache:clear
release: rake db:migrate
