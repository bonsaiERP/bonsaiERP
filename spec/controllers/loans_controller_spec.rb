# encoding: utf-8
require 'spec_helper'

describe LoansController do
  before(:each) do
    stub_auth
    OrganisationSession.set currency_id: 2
  end

  describe "new" do
    it 'should create a new Loanin' do
      get :new, operation: "in"

      assigns(:loan).is_a?(Loanin).should be_true
      response.should render_template("new")
      response.should_not be_redirect
    end

    it 'should create a new Loanout' do
      get :new, operation: "out"

      assigns(:loan).is_a?(Loanout).should be_true
      response.should render_template("new")
      response.should_not be_redirect
    end

    it 'should redirect to loans_path' do
      get :new
      
      response.should redirect_to(loans_path)
      flash[:error].should_not be_blank
    end

    it 'should assing the default currency' do
      get :new, operation: "in"
      
      assigns(:loan).currency_id.should == 2
    end

  end
end
