require 'spec_helper'

feature 'Login' do
  before do
     #create :database
  end

  scenario 'login' do
    visit root_path
  end
end
