# Load the rails application
require File.expand_path('../application', __FILE__)

app_env_vars = Rails.root.join('config', 'app_environment_variables.rb')
raise "The file #{app_env_vars} doesn't exists"  unless File.exists?(app_env_vars)
load(app_env_vars)

# Initialize the rails application
Bonsaierp::Application.initialize!
