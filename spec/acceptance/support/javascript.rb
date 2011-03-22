Rspec.configure do |config|

  config.before(:each) do
    #Capybara.current_driver = :akephalos if example.metadata[:js]
    #Capybara.default_driver = :selenium
    Capybara.configure do |config|
      config.ignore_hidden_elements = false
      config.default_selector = :css
    end
    #require 'selenium-webdriver'
    #profile = Selenium::WebDriver::Firefox::Profile.new
    #profile.native_events = true

    #driver = Selenium::WebDriver.for(:firefox, :profile => profile) 
    #puts "Capybara: #{ Capybara.prefer_visible_elements }"
    Capybara.current_driver = :selenium if example.metadata[:js]
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end

end

