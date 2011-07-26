require 'bundler/setup'
Bundler.require(:default, :development)
require 'spork'
require 'valid_attribute'

# http://railstutorial.org/chapters/static-pages#sec:spork
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV['RAILS_ENV'] ||= 'test'
  
  #unless defined?(Rails)
  #  require File.dirname(__FILE__) + '/../config/environment'
  #end
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'

  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  Rspec.configure do |config|
    config.mock_with :mocha
    
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:all) do
      log.info self.class.description
    end

    config.before(:each) do
      DatabaseCleaner.start
      log.info example.description
    end
   
    config.include Devise::TestHelpers, :type => :controller
    config.after(:each) do
      DatabaseCleaner.clean
    end
    
    config.include AuthMacros

    config.use_transactional_fixtures = false
    # Hack
    ActiveSupport::Dependencies.clear
  end

end

require 'log4r'

module MyLog
  include Log4r

  @@logger = Logger.new('mylog')
  @@format = Log4r::PatternFormatter.new(:pattern => "[ %d ] %l\t %m")
  @@logger.add Log4r::StdoutOutputter.new('console', :formatter => @@format)

  def self.log
    @@logger
  end
end
Spork.each_run do

  Rspec.configure do |config|
    def log
      MyLog.log
    end
  end

end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading 
#   code that you don't normally modify during development in the 
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#




# This file is copied to spec/ when you run 'rails generate rspec:install'
#ENV["RAILS_ENV"] ||= 'test'
#require File.expand_path("../../config/environment", __FILE__)
#require 'rspec/rails'
#
## Requires supporting ruby files with custom matchers and macros, etc,
## in spec/support/ and its subdirectories.
#Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

@@stub_model_methods = {:blank? => false, :is_a? => false, :valid? => true, :destroyed? => false, :new_record? => false}

#RSpec.configure do |config|
#  # == Mock Framework
#  #
#  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
#  #
#  # config.mock_with :mocha
#  # config.mock_with :flexmock
#  # config.mock_with :rr
#  config.mock_with :mocha
#
#  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
#  config.fixture_path = "#{::Rails.root}/spec/fixtures"
#
#  # If you're not using ActiveRecord, or you'd prefer not to run each of your
#  # examples within a transaction, remove the following line or assign false
#  # instead of true.
#  config.use_transactional_fixtures = true
#end
