Bonsaierp::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  #config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { :host => 'localhost' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }
  #config.action_mailer.delivery_method = :sendmail
  #config.action_mailer.sendmail_settings = {
  #  :location => '/usr/sbin/sendmail',
  #  :arguments => '-i -t -f noresponder@bonsaierp.com'
  #}
  #config.action_mailer.delivery_method = :sendmail
  #config.action_mailer.smtp_settings = {
  #  :address => "smtp.gmail.com",
  #  :port => "587",
  #  :domain => "gmail.com",
  #  :user_name => "bonsaierp",
  #  :password => "M4ilBonsa!L4bs",
  #  :authentication => "plain",
  #  :enable_starttls_auto => true
  #}

  #ºconfig.action_mailer.delivery_method = :sendmail
  #ºconfig.action_mailer.sendmail_settings = {:arguments => '-i'}

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
  
  # compile assets
  #config.assets.compile = true

  # Expands the lines which load the assets
  config.assets.debug = true

  # Disable query caching until it's fixed for PostgreSQL schemas
  #config.middleware.delete ActiveRecord::QueryCache
  config.session_store :encrypted_cookie_store, key: '_bonsaierp_session', domain: :all
end

