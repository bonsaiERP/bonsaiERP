if Rails.env.production?
  Bugsnag.configure do |config|
    config.api_key = "5764f05c4e7d87832059e096471f9bc9"
  end
end
