# Edit this Gemfile to bundle your application's dependencies.
source 'http://gemcutter.org'

gem 'rails', '~>3.0.3'

## Bundle edge rails:
# gem "rails", :git => "git://github.com/rails/rails.git"

# ActiveRecord requires a database adapter. By default,
# Rails has selected sqlite3.
#gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'mysql2'


gem 'devise'
gem 'simple_form', '~>1.3.0'
gem 'will_paginate', '~> 3.0.pre2'
gem 'less', '~>1.2.21'
gem 'haml'
gem 'acts-as-taggable-on'
#gem 'escape_utils'

#group :development do
  if RUBY_VERSION == '1.9.2'
    gem 'ruby-debug19', :require => 'ruby-debug'
  else
    gem 'ruby-debug'
  end
#end

group :development do
  gem 'rspec-rails', '~>2.4.1'
  gem 'steak', '~>1.0.0'
end

# Test
group :test do  
  gem 'rspec', '~>2.4.0'
  gem 'mocha'
  gem 'steak', '~>1.0.0'
  gem 'cucumber-rails', '~>0.3.2'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'spork'

  # gem 'database_cleaner'
end  

