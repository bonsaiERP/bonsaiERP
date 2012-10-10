# encoding: utf-8
require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before do
    UserSession.current_user = User.new {|u| u.id = 1}
    create(:currency, id: 10)
    create(:org_country)
  end

  context "Validations" do
    it {should have_valid(:name).when("uno")}
    it {should_not have_valid(:name).when(" ")}

    it {should have_valid(:currency_id).when(10)}
    #it {should_not have_valid(:currency_id).when(1)}
    it { should_not have_valid('tenant').when('common') }
    it { should_not have_valid('tenant').when('public') }
  end


  let(:valid_params) { 
    {
      name:"Test", country_id:1, 
      currency_id:10, tenant: 'another',
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
      {name: 'Firts org', tenant: 'firstorg', 
       email: 'new@mail.com', password: 'secret123'}
    }
    it "creates a new organisation" do
      org = Organisation.new(org_params)

      org.create_organisation.should be_true
      binding.pry
      org
    end
  end
end
