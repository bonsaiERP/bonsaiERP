source :rubygems

gem 'rails', '3.2.9'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'scripts', git: 'git@github.com:boriscy/scripts.git'
end

gem 'turbo-sprockets-rails3'# Speed assets:precompile

#assets javascript gems
gem 'jquery-rails'
gem 'compass-rails'
gem 'coffee-filter'
#gem 'bootstrap-sass', "~> 2.0.0"

gem 'pg'
gem 'virtus'# Model generation in simple way
gem 'encrypted-cookie-store'# Encrypt cookies in the session
gem 'strong_parameters'# Force in controllers to sanitize parameters

gem 'simple_form'
gem 'haml'
gem 'kaminari'
gem 'valium'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'roadie'# Styles for email
gem 'active_model_serializers' # Encode strings with JSON

gem 'validates_email_format_of', '~> 1.5.3'
gem 'queue_classic', '~> 2.0.3' # Background processing for PostgreSQL

gem 'prawn', '~> 1.0.0.rc1'
#gem 'exception_notification', "~> 2.5.2"

group :production do
  gem 'newrelic_rpm'
  gem  'bugsnag'# Report of errors
end

group :development, :test do
  gem 'puma'# Web server
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'rails-footnotes'
  gem 'konacha'
end

# Test
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'spork'
  gem 'shoulda-matchers'
  gem 'valid_attribute'
  gem 'watchr'
  gem 'launchy'
  gem 'log4r'
end

