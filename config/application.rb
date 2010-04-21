require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Bonsaierp
  class Application < Rails::Application
    # Loads all *.rb files form lib/ folder
    Dir.glob(File.join(Rails.root, "lib", "*.rb") ).each{|file| require file}
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )
    #require 'lib/class_extensions'
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :es

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password

    config.secret_token = '4b774a3e141bfb47522cf1cd0f256f2d37acafb0c8623646f97ceb807f7d87bf4d10b334120d749cdc55c1cbb8121ad8caf2e5515833bc0c41082208cd09aff1'
    config.session_store :cookie_store, :key => 'bonsaierp_session'
  end
end
