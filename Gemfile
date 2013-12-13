source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.2'

# Assets
gem 'sass-rails' , '~> 4.0.1'
gem 'coffee-rails' , '~> 4.0.1'
gem 'uglifier'     , '>= 2.3.0'
gem 'jquery-rails'

gem 'assets', git: 'git://github.com/boriscy/assets.git'

# gem 'turbo-sprockets-rails3'# Speed assets:precompile

gem 'compass-rails', '~> 2.0.alpha.0' # Extend css clases
gem 'pg' # Postgresql adapter
gem 'virtus', '~> 0.5.5' # Model generation in simple way
gem 'squeel' # Better SQL queries

gem 'simple_form'
gem 'haml', '>= 4.0.4'
gem 'kaminari' # Pagination
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'active_model_serializers' # ActiveRecord Classes to encode in JSON
gem 'resubject' # Cool presenter

gem 'validates_email_format_of', '~> 1.5.3'
gem 'validates_lengths_from_database'
#gem 'paperclip' # Attachments

group :production do
  gem 'newrelic_rpm'
  gem 'bugsnag' # Report of errors
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'rails_best_practices'
  gem 'quiet_assets'
  gem 'roadie' # Styles for email
end

group :development, :test do
  gem 'puma'# Web server
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'pry-remote' # Work binding.pry_remote with Foreman, just call pry-remote in the terminal
  gem 'pry'#, '0.9.11.3'# 0.9.11.4 gives error
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'foreman'
end

# Test
  gem 'capybara'
group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails', '~> 4.3.0'
  gem 'spork', '1.0.0rc4' # Newer version gives error with squeel
  gem 'shoulda-matchers' #, '1.4.2'
  gem 'valid_attribute'
  gem 'watchr'
  gem 'launchy'
end
