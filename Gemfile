source :rubygems

gem 'rails', '3.2.11'

group :assets do
  gem 'sass-rails'   , '~> 3.2.5'
  gem 'coffee-rails' , '~> 3.2.2'
  gem 'uglifier'     , '~> 1.3.0'
  gem 'scripts'      , git: 'git://github.com/boriscy/scripts.git'
end

gem 'turbo-sprockets-rails3'# Speed assets:precompile

#assets javascript gems
gem 'jquery-rails'
gem 'compass-rails'
gem 'coffee-filter'
#gem 'bootstrap-sass'

gem 'pg'
gem 'virtus' # Model generation in simple way
gem 'encrypted-cookie-store' # Encrypt cookies in the session
gem 'strong_parameters' # Force in controllers to sanitize parameters
gem 'squeel' # Better SQL queries

gem 'simple_form'
gem 'haml'
gem 'kaminari'
gem 'valium'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'roadie' # Styles for email
gem 'active_model_serializers' # Encode strings with JSON
gem 'resubject' # Cool presenter

gem 'validates_email_format_of', '~> 1.5.3'
gem 'queue_classic' # Background processing for PostgreSQL

gem 'prawn', '~> 1.0.0.rc1'
#gem 'exception_notification'

group :production do
  gem 'newrelic_rpm'
  gem 'bugsnag' # Report of errors
end

group :development, :test do
  gem 'puma'# Web server
  gem 'rspec-rails'
  gem 'ffaker'
  gem 'pry-remote' # Work binding.pry_remote with Foreman, just call pry-remote in the terminal
  gem 'pry-rails'
  gem 'pry-nav'
  gem 'rails-footnotes'
  gem 'konacha'
  gem 'foreman'
  #gem 'quiet_assets' # Quiets assets log in development
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
