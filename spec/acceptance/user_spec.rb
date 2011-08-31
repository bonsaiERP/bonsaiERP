# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test users" do
  let(:user_params) {
    {
      :email => "user2@example.com", :abbreviation => "USER2", 
      :first_name => "Other", :last_name => "User",
      :phone => "32423424", :mobile => "6732643",
      :address => "Somewhere", :rolname => "gerency"
    }
  }

  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new {|u| u.id = 1}
  end

  scenario "add a new user" do
    u = User.new
    u.add_company_user(user_params).should be_true
    u.abbreviation.should == user_params[:abbreviation]
    u.reload

    u.links.should have(1).element
    l = u.links.first
    l.should be_persisted
    l.abbreviation.should == user_params[:abbreviation]
    l.rol.should == "gerency"

    ActionMailer::Base.deliveries.should_not be_empty

    mail = ActionMailer::Base.deliveries.first
    mail.subject.should == I18n.t("bonsai.registration")
    mail.to.should == [u.email]

    mail.encoded.should =~ /Bienvenido a/
    mail.encoded.should =~ /\/registrations\/#{u.id}/
  end

  scenario "invalid params" do

  end
end
