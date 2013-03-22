# encoding: utf-8
require 'spec_helper'

describe AdminUser do
  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, id: 15, tenant: 'bonsai'
  end

  let(:valid_attributes) {
    {
      email: 'new_user@mail.com', first_name: 'New', last_name: 'User',
      rol: 'group'
    }
  }

  context "add user" do
    it "creates a new user" do
      Link.any_instance.stub(save: true)
      User.any_instance.stub(save: true)

      ad = AdminUser.new(User.new(valid_attributes))
      # Check email is send
      RegistrationMailer.should_receive(:user_registration).with(ad).and_return(stub(deliver: true))

      ad.add_user.should be_true

      ad.user.password.should_not be_blank
      ad.user.password_confirmation.should eq ad.user.password
      ad.user.should be_change_default_password
      ad.user.rol.should eq('group')
      ad.user.should be_active

      lnk = ad.user.active_links.first
      lnk.organisation_id.should eq(15)
      lnk.rol.should eq('group')
      lnk.should be_active
      lnk.tenant.should eq('bonsai')
    end

    it "doesn't permit admin as param" do
      Link.any_instance.stub(save: true)
      User.any_instance.stub(save: true)

      ad = AdminUser.new(User.new(valid_attributes.merge(rol: 'admin')))
      ad.add_user.should be_true
      
      ad.user.active_links.first.rol.should eq('other')
    end
  end

  context "update" do
    it "updates"
  end
end
