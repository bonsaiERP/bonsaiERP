# encoding: utf-8
require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before do
    UserSession.user = build :user, id: 1
  end

  context "Validations" do
    it {should have_valid(:name).when("uno")}
    it {should_not have_valid(:name).when(" ", nil)}

    it { should_not have_valid('tenant').when('common', 'public', 'www', 'demo') }
    it { should have_valid('tenant').when('bonsai', 'other') }

    context 'Persisted organisation' do
      subject(:organisation) { 
        org = build :organisation, id: 10 
        org.stub(persisted?: true)
        org
      }

      it {should have_valid(:currency).when('BOB', 'USD')}
      it {should_not have_valid(:currency).when('', 'USDS')}

      it { should have_valid(:country_code).when('BO', 'PE') }
      it { should_not have_valid(:country_code).when('BOS', 'PES') }

      it { should have_valid(:email).when('', '  ', nil) }
      it { should have_valid(:email).when('test@mail.com', 'james@mail.co.uk') }
      it { should_not have_valid(:email).when('test@mail.c', 'james@mail' 'h') }
    end
  end


  let(:valid_params) { 
    {
      name:"Test", country_id:1, 
      currency: 'BOB', tenant: 'another',
      address: "Very near" 
    }
  }

  it "create an instance" do
    org = Organisation.create!(valid_params)
  end

  it "build master_account user" do
    org = Organisation.new
    org.build_master_account

    org.master_link.should be_master_account
    org.master_link.should be_creator
    org.master_link.rol.should eq('admin')

    org.master_link.user.should be_present
  end

  context 'create_organisation' do
    let(:org_params) {
      {name: 'Firts org', tenant: 'firstorg', email: 'new@mail.com' }
    }
    let(:country) { OrgCountry.first }

    it "creates a new organisation" do
      org = Organisation.new(org_params)

      org.save.should be_true
    end

  end
end
