source 'https://rubygems.org'

ruby '2.3.1'
gem 'rails', '4.2.7.1'

# Assets
gem 'sass-rails', '~> 5.0.1'
gem 'coffee-rails' , '~> 4.0.1'
gem 'uglifier' , '>= 2.7.0'

gem 'compass-rails', '~> 2.0.4'
gem 'pg' # Postgresql adapter
gem 'virtus' # Model generation in simple way
#gem 'squeel' # Better SQL queries

gem 'simple_form'
gem 'haml', '>= 4.0.5'
gem 'kaminari' # Pagination
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'active_model_serializers' # ActiveRecord Classes to encode in JSON
gem 'resubject' # Cool presenter

gem 'validates_email_format_of'#, '~> 1.5.3'
gem 'validates_lengths_from_database'
# Hstore accessor
gem 'hstore_accessor'
gem 'jsonb_accessor'

gem 'dragonfly'

gem "rack-cors", require: "rack/cors"

gem "responders", "~> 2.0"

group :production do
  gem 'newrelic_rpm'
  gem 'bugsnag' # Report of errors
  gem 'rack-cache', require: 'rack/cache'
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "meta_request"
  gem "rails_best_practices"
  gem "quiet_assets"
  gem "bullet"
  gem "awesome_print"

  gem "capistrano"#, '~> 3.2.0'
  gem "capistrano-rails"#, '~> 1.1'
  gem "capistrano-bundler"
  gem "capistrano-rvm"
end

group :development, :test do
  gem "puma"# Web server
  gem "spring-commands-rspec"
  gem "rspec-rails"#, '2.99.0'
  gem "ffaker"
  gem "pry-byebug"
end

# Test
group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "factory_girl_rails"#, '~> 4.4.1'
  gem "shoulda-matchers", require: false
  gem "valid_attribute"
  gem "watchr"
  gem "launchy"
end
