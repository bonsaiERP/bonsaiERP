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
      {name: 'Firts org', tenant: 'firstorg', email: 'new@mail.com', password: 'secret123'}
    }
    let(:country) { OrgCountry.first }
    let(:currency) { Currency.first }

    it "creates a new organisation" do
      org = Organisation.new(org_params)

      org.create_organisation.should be_true

      org.master_link.should be_persisted
      org.master_link.rol.should eq('admin')
      org.master_link.should be_master_account

      org.master_link.user.should be_persisted
      org.master_link.user.email.should eq(org_params[:email])

      org.master_account.should be_is_a(User)
      org.master_account.should be_persisted
    end

    it "should present errors if no email or password" do
      org = Organisation.new(org_params.merge(email: '', password: '') )

      org.create_organisation.should be_false
      org.errors[:email].should be_include I18n.t("activerecord.errors.messages.blank")
      org.errors[:password].should be_include I18n.t("activerecord.errors.messages.too_short", count: PASSWORD_LENGTH)

      org = Organisation.new(org_params.merge(email: 'na@mail', password: 'demo1234') )

      org.create_organisation.should be_false
      org.errors[:email].should be_include I18n.t("errors.messages.user.email")
    end
  end
end
