# encoding: utf-8
require 'spec_helper'

describe AdminUser do
  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, id: 15
  end

  let(:valid_attributes) {
    {
      email: 'new_user@mail.com', first_name: 'New', last_name: 'User',
      rol: 'gerency'
    }
  }

  context "add user" do
    it "creates a new user" do
      Link.any_instance.stub(save: true)
      User.any_instance.stub(save: true)

      ad = AdminUser.new(User.new(valid_attributes))
      ad.add_user.should be_true

      ad.user.password.should_not be_blank
      ad.user.should be_change_default_password
      ad.user.rol.should eq('gerency')
      ad.user.should be_active

      lnk = ad.user.links.first
      lnk.organisation_id.should eq(15)
      lnk.rol.should eq('gerency')
      lnk.should be_active
    end

    it "doesn't permit admin as param" do
      Link.any_instance.stub(save: true)
      User.any_instance.stub(save: true)

      ad = AdminUser.new(User.new(valid_attributes.merge(rol: 'admin')))
      ad.add_user.should be_true
      
      ad.user.links.first.rol.should eq('operations')
    end
  end
end
