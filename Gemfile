# Edit this Gemfile to bundle your application's dependencies.
source 'http://gemcutter.org'

gem 'rails', '~> 3.1.1'

## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.1"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'pg'
#gem 'mysql2'#, :group => :production
#gem 'sqlite3-ruby', :group => [:development, :text]

gem 'simple_form'
gem 'haml'
gem 'kaminari'
gem 'valium'
gem 'bcrypt-ruby'
#gem 'qu-redis'
gem 'resque', :require => 'resque/server'

#gem 'nokogiri'

gem 'prawn', '~>0.12.0'
#gem 'newrelic_rpm'
#gem 'escape_utils'

group :development, :test do
  gem 'rspec-rails', '~> 2.7.0'
  gem 'steak', '~> 2.0.0'
  gem 'jasmine'
  gem 'headless'
end

group :development do
  gem 'ruby-debug19', '~> 0.11.6', :platform => :mri_19, :require => 'ruby-debug'
  #gem 'active_reload'
  gem 'pry'
  gem 'ffaker', '~> 1.8.0'
  gem 'factory_girl_rails'
end


# Test
group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'spork', '~> 0.9.0.rc9'
  gem 'watchr'
  gem 'launchy'
  gem 'turn', :require => false
  gem 'valid_attribute'
  gem 'log4r'
end  

