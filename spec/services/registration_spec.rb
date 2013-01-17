# encoding: utf-8
require "spec_helper"

describe Registration do
  let(:valid_attributes) do
    {name: 'bonsaiERP', tenant: 'bonsai', email: 'boris@bonsaierp.com',
     password: 'demo123', password_confirmation: 'demo123'}
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
end
