require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret "c641addee1481dcfdcc372ba25ee76a433a8ecbf5721b805df5db6e509dce230"

  url_format "/media/:job/:name"

  if Rails.env.production?
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
    #datastore :s3,
    #  bucket_name: Rails.application.secrets.s3_bucket_name,
    #  access_key_id: Rails.application.secrets.s3_access_key_id,
    #  secret_access_key: Rails.application.secrets.s3_secret_access_key,
    #  url_scheme: Rails.application.secrets.url_scheme
  else
    datastore :file,
      root_path: Rails.root.join('public/system/dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  end

end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
