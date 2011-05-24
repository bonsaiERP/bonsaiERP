Rspec.configure do |config|

  config.before(:each) do
    Capybara.default_driver = :selenium
    Capybara.configure do |config|
      config.ignore_hidden_elements = false
      config.default_selector = :css
    end
    Capybara.current_driver = :selenium if example.metadata[:js]
  end

  config.after(:each) do
    Capybara.use_default_driver if example.metadata[:js]
  end

end

