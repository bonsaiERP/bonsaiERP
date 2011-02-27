require 'akephalos'

Rspec.configure do |config|

  config.before(:each) do
    Capybara.current_driver = :akephalos if example.metadata[:js]
    #Capybara.current_driver = :selenium #if example.metadata[:js]
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end

end

