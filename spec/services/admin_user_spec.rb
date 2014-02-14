# encoding: utf-8
require 'spec_helper'

describe AdminUser do
  before(:each) do
    UserSession.user = build :user, id: 10
  end

  let!(:organisation) { create :organisation, id: 15, tenant: 'bonsaierp' }
  let(:attributes) {
    {
      email: 'new_user@mail.com', first_name: 'New', last_name: 'User', role: 'group', organisation: organisation
    }
  }

  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:organisation) }
  it { should validate_presence_of(:role) }

  it { should have_valid(:role).when('group', 'other') }
  it { should_not have_valid(:role).when('admin', nil, 'je', 'grupo') }

  it "create" do
    au = AdminUser.new(attributes)
    RegistrationMailer.should_receive(:user_registration).with(au).and_return(double(deliver!: true))

    au.create.should be_true
    au.user.should be_persisted
    attributes.except(:organisation, :role).each do |k, v|
      au.user.send(k).should eq(v)
    end

    link = au.user.active_links.first
    link.should be_persisted
    link.organisation_id.should eq(15)
    link.role.should eq('group')

    # Invalid user, repeated email

    au = AdminUser.new(attributes)
    au.create.should be_false
    au.errors.messages[:email].should eq([I18n.t('errors.messages.email_taken')])
  end

  it "update" do
    au = AdminUser.new(attributes)
    RegistrationMailer.should_receive(:user_registration).with(au).and_return(double(deliver!: true))

    au.create.should be_true
    user = au.user
    link = au.link

    au = AdminUser.find(organisation, user.id)
    au.user.should eq(user)
    au.link.should eq(link)

    au.update(attributes.merge(email: 'otheremail@mail.com', role: 'other')).should be_true


    au.user.email.should eq('otheremail@mail.com')
    au.user.should_not be_changed

    au.link.role.should eq('other')
    au.link.should_not be_changed
  end

  #it "send_email" do
    #au = AdminUser.new(attributes)
    #RegistrationMailer.should_receive(:user_registration).with(au).and_return(double(deliver!: true))

    #au.create.should be_true
    #user = au.user

    #au = AdminUser.find(organisation, user.id)

    #RegistrationMailer.should_receive(:user_registration).with(au).and_return(double(deliver!: true))

    #au.send_email
  #end

end
