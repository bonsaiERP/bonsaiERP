source 'https://rubygems.org'

gem 'rails', '3.2.13'

group :assets do
  gem 'sass-rails'   , '~> 3.2.5'
  gem 'coffee-rails' , '~> 3.2.2'
  gem 'uglifier'     , '~> 1.3.0'
  gem 'jquery-rails'
  gem 'teabag' # Testing for javascript
  gem 'assets'      , git: 'git://github.com/boriscy/assets.git'
  gem 'turbo-sprockets-rails3'# Speed assets:precompile
end

gem 'compass-rails' # Extend css clases
gem 'pg' # Postgresql adapter
gem 'virtus' # Model generation in simple way
gem 'encrypted-cookie-store' # Encrypt cookies in the session
gem 'strong_parameters' # Force in controllers to sanitize parameters
gem 'squeel' # Better SQL queries

gem 'simple_form'
gem 'haml', '~> 4.0.1'
gem 'kaminari' # Pagination
gem 'valium' # Better than pluck method
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'active_model_serializers' # ActiveRecord Classes to encode in JSON
gem 'resubject' # Cool presenter

gem 'validates_email_format_of', '~> 1.5.3'
gem 'paperclip' # Attachments


gem 'prawn', '~> 1.0.0.rc2'
#gem 'exception_notification'

group :production do
  gem 'newrelic_rpm'
  gem 'bugsnag' # Report of errors
end

group :development do
  gem 'puma'# Web server
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rails_best_practices'
  gem 'quiet_assets'
  gem 'roadie' # Styles for email
end

group :development, :test do
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'pry-remote' # Work binding.pry_remote with Foreman, just call pry-remote in the terminal
  gem 'pry'#, '0.9.11.3'# 0.9.11.4 gives error
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'foreman'
end

# Test
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'spork', '0.9.2' # Newer version gives error with squeel
  gem 'shoulda-matchers', '1.4.2'
  gem 'valid_attribute'
  gem 'watchr'
  gem 'launchy'
end
