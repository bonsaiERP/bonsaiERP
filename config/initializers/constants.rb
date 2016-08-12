PASSWORD_LENGTH = 8
DOMAIN = Rails.application.secrets.domain
ENV["DOMAIN"] = DOMAIN
USE_SUBDOMAIN = false
HTTP_PROTOCOL = Rails.application.secrets.http_protocol
#ENV['MANDRILL_API_KEY'] = Rails.application.secrets.mandrill_api_key
DEV_DOMAIN = 'localhost.bom'
APP_NAME = 'bonsaiERP'
ALLOW_REGISTRATIONS = Rails.application.secrets.allow_registration
INPUT_SIZE = 45
INVALID_TENANTS = %w(www public common demo app test)
#S3_BUCKET = Rails.application.secrets.s3_bucket_name

STATUS_ERROR = 422
