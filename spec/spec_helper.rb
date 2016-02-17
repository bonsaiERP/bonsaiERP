# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
#require 'rspec/autorun'

require "shoulda/matchers"
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
#require 'capybara/poltergeist'
#Capybara.register_driver :poltergeist_debug do |app|
#  Capybara::Poltergeist::Driver.new(app, inspector: true, js_errors: false)
#end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.infer_base_class_for_anonymous_controllers = false

  config.use_transactional_fixtures = false

  config.order = "random"

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }

  config.infer_spec_type_from_file_location!

  config.before(:suite) do
    # So it does not clean migrations
    DatabaseCleaner.clean_with(:truncation, { except: %w(schema_migrations) })
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods
  config.include Request::JsonHelpers, type: :controller
  config.include AuthMacros, type: :controller
end
