# Edit this Gemfile to bundle your application's dependencies.
source :rubygems

gem 'rails', ">= 3.2.2"

## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   "~> 3.2.4"
  gem 'coffee-rails', "~> 3.2.2"
  gem 'uglifier',     ">= 1.2.3"
end

gem 'jquery-rails', "~> 2.0.1"
gem 'compass-rails', "~> 1.0.0"
#gem 'bootstrap-sass', "~> 2.0.0"
gem 'ramon', "~> 0.4.0"

gem 'pg', "~> 0.13.2"
#gem 'mysql2'#, :group => :production
#gem 'sqlite3-ruby', :group => [:development, :text]

gem 'simple_form', "~> 2.0.1"
gem 'haml',        "~> 3.1.4"
gem 'kaminari',    "~> 0.13.0"
gem 'valium',      "~> 0.5.0"
gem 'bcrypt-ruby', "~> 3.0.1"
gem 'qu-redis',    "~> 0.1.4"
#gem 'resque', :require => 'resque/server'

#gem 'nokogiri'

gem 'prawn', '~> 1.0.0.rc1'
#gem 'exception_notification', "~> 2.5.2"
#gem 'newrelic_rpm'

group :development, :test do
  gem 'rspec-rails', '~> 2.8.1'
  gem 'steak', '~> 2.0.0'
  #gem 'jasmine'
  #gem 'headless'
  #gem 'jasminerice'
end

group :development do
  #gem 'linecache19' #, :git => "git://github.com/mark-moseley/linecache.git"
  gem 'ruby-debug19', '~> 0.11.6', :platform => :mri_19, :require => 'ruby-debug'
  #gem 'pry',                "~> 0.9.8.4"
  gem 'ffaker',             "~> 1.13.0"
  gem 'pry-rails', "~> 0.1.6"
end


# Test
group :test do
  gem 'capybara',           "~> 1.1.2"
  gem 'database_cleaner',   "~> 0.7.1"
  gem 'factory_girl_rails', "~> 1.7.0"
  gem 'spork',              "~> 0.9.0"
  gem 'valid_attribute',    "~> 1.2.0"
  gem 'watchr'
  gem 'launchy'
  gem 'turn', :require => false
  gem 'log4r'
end  

