# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

require 'shoulda/matchers'

require 'capybara/poltergeist'
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true, js_errors: false)
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.before(:suite) do
    # So it does not clean migrations
    #DatabaseCleaner.strategy = :truncation, { except: %w(schema_migrations) }
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, { except: %w(schema_migrations) })
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  #config.include Devise::TestHelpers, :type => :controller
  config.after(:each) do
    DatabaseCleaner.clean
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Include factory methods in Rspec
  config.include FactoryGirl::Syntax::Methods
end
