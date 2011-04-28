ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => "587",
  :domain => "bonsaierp.com",
  :user_name => "demo213",
  :password => "Demo1234",
  :authentication => "plain",
  :enable_starttls_auto => true
}
#ActionMailer::Base.delivery_method = :sendmail
#ActionMailer::Base.smtp_settings = {
#  :address              => "smtp.gmail.com",            
#  :port                 => 587,   
#  :domain               => "test.com",  
#  :user_name            => "bonsaierp",#"demo123prueba", 
#  :password             => "Demo1234",  
#  :authentication       => "plain",  
#  :enable_starttls_auto => true   
#} 
#ActionMailer::Base.default_url_options[:host] = "localhost:3000"
#Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?
