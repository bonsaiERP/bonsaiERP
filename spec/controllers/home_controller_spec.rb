require 'spec_helper'

describe HomeController do
  it "should asing page" do
    get :index
    assigns(:page).should eq("home")
  end

  it 'should assing page in case that params have page' do
    get :index, :page => 'team'
    assigns(:page).should eq("team")
  end
end

