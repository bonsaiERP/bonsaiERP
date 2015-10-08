require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
#Bundler.require(:default, Rails.env)
Bundler.require(*Rails.groups)

module Bonsaierp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app/forms)

    config.assets.paths << Rails.root.join('vendor', 'assets')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'La Paz'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.default_locale = :es

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    config.assets.precompile += %w(angular/angular-file-upload-shim.min.js email.css)

    config.active_record.schema_format = :sql

    # Generators
    config.generators do |g|
      g.template_engine :haml
      g.helper = false
      g.stylesheet_engine = :sass
      g.stylesheets = false
      g.javascripts = false
    end

    # Error pages exceptions
    # config.exceptions_app = self.routes

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

  end
end

I18n.enforce_available_locales = false
