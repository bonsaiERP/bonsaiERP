# encoding: utf-8
require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before do
    UserSession.current_user = User.new {|u| u.id = 1}
    Factory(:currency, id: 10)
    Factory(:org_country)
  end

  it {should have_valid(:name).when("uno")}
  it {should_not have_valid(:name).when(" ")}

  it {should have_valid(:currency_id).when(10)}
  #it {should_not have_valid(:currency_id).when(1)}

  let(:valid_params) { {name:"Test", country_id:1, currency_id:10, address: "Very near" } }

  it 'should create an instance' do
    org = Organisation.create!(valid_params)
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
