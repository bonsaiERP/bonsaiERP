require 'bundler/setup'
Bundler.require(:default, :development)
#require 'spork'
require 'valid_attribute'

# http://railstutorial.org/chapters/static-pages#sec:spork
Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  ENV['RAILS_ENV'] ||= 'test'

  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'capybara/rspec'


  RSpec.configure do |config|
    config.mock_with :rspec

    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    #config.before(:all) do
    #  log.info self.class.description
    #end

    config.before(:each) do
      DatabaseCleaner.start
      # Create schema and database
      #unless PgTools.schema_exists?("schema1")
      #  PgTools.create_schema("schema1")
      #  #Rake::Task["bonsai:migrate_schemas"].execute
      #end
      #log.info example.description
    end

    #config.include Devise::TestHelpers, :type => :controller
    config.after(:each) do
      DatabaseCleaner.clean
    end


    config.use_transactional_fixtures = false

    # Include factory methods in Rspec
    config.include FactoryGirl::Syntax::Methods
    # Hack
    ActiveSupport::Dependencies.clear
  end

end

#require 'log4r'

#module MyLog
  #include Log4r

  #@@logger = Logger.new('mylog')
  #@@format = Log4r::PatternFormatter.new(:pattern => "[ %d ] %l\t %m")
  #@@logger.add Log4r::StdoutOutputter.new('console', :formatter => @@format)

  #def self.log
    #@@logger
  #end
#end

Spork.each_run do
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    #def log
      #MyLog.log
    #end
    config.include Helpers
  end

  #include Helpers
  FactoryGirl.reload
end
