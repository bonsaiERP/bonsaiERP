# encoding: utf-8
require "spec_helper"

describe Registration do
  let(:valid_attributes) do
    {name: 'bonsaiERP', tenant: 'bonsai', email: 'boris@bonsaierp.com',
     password: 'Demo1234', password_confirmation: 'Demo1234'}
  end

  it { should have_valid(:email).when('boris@mail.com', 'si@me.com.bo') }
  it { should_not have_valid(:email).when('  ', 'si@me.com.') }
  
  it { should have_valid(:name).when('no', 'si', 'ahor que niño') }
  it { should_not have_valid(:name).when(nil, '   ', '') }

  it { should have_valid(:tenant).when('si', 'de', '7k', '99', 'bonsai') }
  it { should_not have_valid(:tenant).when('s', nil, '   ', '7-k', 's2@') }

  it { should have_valid(:password).when('Demo1234') }
  it { should_not have_valid(:password_confirmation).when('  ', nil) }

  it "error for password" do
    r = Registration.new(password: 'Demo1234', password_confirmation: '')
    r.register.should be_false

    r.errors_on(:password).should eq( [I18n.t('errors.messages.confirmation') ] )
  end

  it "registrates" do
    User.any_instance.stub(save: true, id: 1)
    Organisation.any_instance.stub(save: true, id: 1)

    r = Registration.new(valid_attributes)
    r.register.should be_true

    r.organisation.name.should eq('bonsaiERP')
    r.organisation.tenant.should eq('bonsai')

    r.user.email.should eq('boris@bonsaierp.com')
    r.user.encrypted_password.should_not be_blank

    link = r.user.links.first
    link.organisation_id.should eq(1)
    link.rol.should eq('admin')
    link.should be_master_account
    link.tenant.should eq('bonsai')
  end
end
