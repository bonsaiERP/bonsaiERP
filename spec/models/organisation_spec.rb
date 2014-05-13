# encoding: utf-8
require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before do
    UserSession.user = build :user, id: 1
  end

  it { Organisation.table_name.should eq('common.organisations') }

  context "Validations" do
    it { should have_valid(:name).when("uno") }
    it { should_not have_valid(:name).when(" ", nil) }


    it "tenant" do
      org = Organisation.new
      INVALID_TENANTS.each do |v|
        org.name = v
        org.should_not be_valid
        org.errors[:tenant].should_not be_blank
      end

      %w(bonsaii bonsaiERP unoY-23 asdf\ 77Ad).each do |v|
        org.name = v
        org.should be_valid
        org.tenant.should eq(v.downcase.gsub(/[^A-Za-z]/, ''))
      end

      org.name = 'Prueba uno 1 a(1)'
      org.should be_valid
      org.tenant.should eq('pruebaunoa')
    end

    context 'Persisted organisation' do
      subject(:organisation) {
        org = build :organisation, id: 10
        org.stub(persisted?: true)
        org
      }

      it { should have_valid(:currency).when('BOB', 'USD') }
      it { should_not have_valid(:currency).when('', 'USDS') }

      it { should have_valid(:country_code).when('BO', 'PE') }
      it { should_not have_valid(:country_code).when('BOS', 'PES') }

      it { should have_valid(:email).when('', '  ', nil) }
      it { should have_valid(:email).when('test@mail.com', 'james@mail.co.uk') }
      it { should_not have_valid(:email).when('test@mail.c', 'james@mail' 'h') }
    end
  end

  it "tenant creation" do
    org = Organisation.create!(name: 'Prueba')
    org.tenant.should eq('prueba')

    org = Organisation.create!(name: 'Prueba')
    org.tenant.should_not eq('prueba')
  end

  it "create an instance" do
    Organisation.delete_all
    Organisation.create!(name: 'tenant')
    org = Organisation.new(name: 'jejeje')
    org.save.should be_true
    org.tenant.should eq('jejeje')
  end

  it "build master_account user" do
    org = Organisation.new
    org.build_master_account

    org.master_link.should be_master_account
    org.master_link.should be_creator
    org.master_link.role.should eq('admin')

    org.master_link.user.should be_present
  end

  context 'create_organisation' do
    let(:org_params) {
      {name: 'Firts org', tenant: 'firstorg', email: 'new@mail.com', country_code: 'BO', currency: 'BOB',
      inventory_active: true }
    }

    let(:country) { OrgCountry.first }

    it "creates a new organisation" do
      org = Organisation.new(org_params)

      org.save.should be_true
    end

    it "inventory_active" do
      org = Organisation.new(org_params)

      org.save.should be_true
      org.inventory_active.should be_true
      org.should be_persisted

      org.inventory_active = false
      org.attributes = {country_code: 'BO', currency: 'BOB'}

      org.save.should be_true
      org.inventory_active.should be_false
    end

  end

  it "#currency_klass" do
    org = Organisation.new(currency: 'BOB')
    org.currency.should eq('BOB')
    org.currency_to_s.should eq('BOB Boliviano')
    org.currency_name.should eq('Boliviano')
  end

  it "#valid_header_css" do
    org = Organisation.new
    org.valid?
    expect(org.header_css).to eq('bonsai-header')

    Organisation::HEADER_CSS.each do |css|
      org.header_css = css
      org.valid?
      expect(org.header_css).to eq(css)
    end

    org.header_css = 'non'
    org.valid?
    expect(org.header_css).to eq('bonsai-header')
  end
end
