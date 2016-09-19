if Rails.env.production? && Rails.application.secrets[:use_bugsnag]
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets[:bugsnag_api_key]
  end
end
