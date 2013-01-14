# encoding: utf-8
require 'spec_helper'

describe UserSession do

  it "sets a user correctly" do
    UserSession.user = build :user, id: 12, email: 'user@mail.com'

    UserSession.user.should be_is_a(User)
    UserSession.id.should eq(12)
    UserSession.email.should eq('user@mail.com')
  end

  it "destroys the user session" do
    UserSession.user = build :user, id: 12, email: 'user@mail.com'

    UserSession.id.should eq(12)
    UserSession.user.should be_is_a(User)
    UserSession.destroy

    UserSession.user.should be_nil
  end

  it "raises errors when is not set user" do
    expect { UserSession.user = Date.new }.to raise_error
  end
end
