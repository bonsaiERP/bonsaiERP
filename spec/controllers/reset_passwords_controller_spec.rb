require 'spec_helper'

describe ResetPasswordsController do
  before(:each) do

  end

  describe 'GET /reset_passwords/new' do
    it "renders the new" do
      get :new

      response.should be_success
      response.should render_template('new')
    end
  end

  describe 'GET /reset_passwords/:id/show' do

  end

  describe 'POST /reset_passwords' do

  end
end
