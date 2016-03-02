if Rails.env.production? && Rails.application.secretes[:use_bugsnag]
  Bugsnag.configure do |config|
    config.api_key = Rails.application.secrets[:bugsnag_api_key]
  end
end
