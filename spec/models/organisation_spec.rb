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

  describe "Create records" do
    let!(:org) { Organisation.create!(valid_params)}

    it 'should create units' do
      org.create_records
      Unit.should be_any
    end

    it 'should create all currencies' do
      org.create_records
      AccountType.should be_any
    end

    it 'should create all currencies' do
      org.create_records
      Currency.should be_any
      Currency.count.should > 2
    end
  end

end
