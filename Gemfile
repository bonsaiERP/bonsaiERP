# Edit this Gemfile to bundle your application's dependencies.
source 'http://gemcutter.org'

gem 'rails', '~>3.1.0'

## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
#gem 'sqlite3-ruby', :require => 'sqlite3'
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

gem 'jquery-rails'

gem 'mysql2'

gem 'simple_form'
gem 'haml'
gem 'kaminari'
gem 'valium'

gem 'nokogiri'

gem 'prawn', '~>0.12.0', :git => 'https://github.com/sandal/prawn.git', :branch => "stable", :submodules => true
#gem 'newrelic_rpm'
#gem 'escape_utils'

group :development do
  gem 'ruby-debug19', :platform => :mri_19, :require => 'ruby-debug'
  gem 'active_reload'
  gem 'pry'
  gem 'rspec-rails', '~>2.6.0'
  gem 'steak', '~>2.0.0'
  gem 'ffaker', '~> 1.8.0'
  gem 'factory_girl_rails'
  gem 'jasmine'
end


# Test
group :test do
  gem 'rspec-rails', '~>2.6.0'
  gem 'mocha'
  gem 'steak', '~>2.0.0'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'jasmine'
  gem 'spork', '~>0.9.0.rc9'
  gem 'database_cleaner'
  gem 'watchr'
  gem 'launchy'
  gem 'turn', :require => false
  gem 'valid_attribute'
  gem 'log4r'
end  

