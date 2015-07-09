# encoding: utf-8
require "spec_helper"

describe Registration do
  let(:valid_attributes) do
    {name: 'bonsaiERP', email: 'borisb@bonsaierp.com',
     password: 'Demo1234'}
  end

  it { should have_valid(:email).when('borisb@mail.com', 'si@me.com.bo') }
  it { should_not have_valid(:email).when('  ', 'si@me.com.') }

  it { should have_valid(:name).when('no', 'si', 'ahor que niño') }
  it { should_not have_valid(:name).when(nil, '   ', '') }


  it { should have_valid(:password).when('Demo1234') }

  it "registrates" do
    r = Registration.new(valid_attributes)
    r.register.should eq(true)

    r.organisation.name.should eq('bonsaiERP')
    r.organisation.tenant.should eq('bonsaierp')
    r.tenant.should eq('bonsaierp')
    r.organisation.should be_inventory

    r.user.email.should eq(valid_attributes[:email])
    r.user.encrypted_password.should_not be_blank
    r.user.confirmation_token.should_not be_blank
    r.user.password.should_not be_blank

    link = r.user.active_links.first
    link.organisation_id.should eq(r.organisation.id)
    link.role.should eq('admin')
    link.should be_master_account
    link.tenant.should eq('bonsaierp')

    link.api_token.length.should > 10
  end
end
