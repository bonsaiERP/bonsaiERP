# encoding: utf-8
require 'spec_helper'
#require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before do
    UserSession.user = build :user, id: 1
  end

  context 'jsonb_accessor' do
    it "test set" do
      org = Organisation.new(inventory: true, header_css: "red-header")

      expect(org.inventory).to eq(true)
      expect(org.header_css).to eq("red-header")
    end

    it "types" do
      org = Organisation.new(inventory: "t", header_css: "red-header")

      expect(org.inventory).to eq(true)
      expect(org.inventory_change).to eq([nil, true])
      org.save(validate: false)
      org.reload

      org.inventory = "f"
      expect(org.inventory).to eq(false)
      expect(org.inventory_change).to eq([true, false])
    end

    it "attributes" do
      org = Organisation.new
      [:inventory, :header_css].each do |field|
        expect(org.attributes.key?(field.to_s)).to eq(true)
      end
    end
  end

  describe 'relationships'  do
    #it { should have_many(:links) }
    #it { should have_many(:master_links) }
    #it { should have_many(:users).through(:links).dependent(:destroy) }


    it "#active_users" do
      org = build :organisation, tenant: 'esp'
      org.save(validate: false)
      u = build :user
      u.save(validate: false)
      Link.create!(tenant: 'esp', user_id: u.id, organisation_id: org.id, role: 'admin', master_account: true)

      expect(org.active_users.to_sql).to match(/links.active = 't'/)

      expect(org.links.count).to eq(1)

      sql = org.master_links.to_sql
      expect(sql).to match(/"links"."master_account" = 't'/)
      expect(sql).to match(/"links"."role" = 'admin'/)

      expect(org.users).to eq([u])
    end
  end

  it { Organisation.table_name.should eq('common.organisations') }

  it "defaults" do
    org = Organisation.new
    expect(org.plan).to eq('2users')
  end

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
    d = 1.month.from_now
    org = Organisation.new(name: 'jejeje', due_on: d)
    expect(org.save).to eq(true)
    expect(org.tenant).to eq('jejeje')
    expect(org.due_on).to eq(d.to_date)
  end

  it "build master_account user" do
    org = Organisation.new(tenant: 'bonsaierp')
    link = org.master_links.build(creator: true)

    expect(link.master_account?).to eq(true)
    expect(link.creator?).to eq(true)
    link.role.should eq('admin')
  end

  context 'create_organisation' do
    let(:org_params) {
      {name: 'Firts org', tenant: 'firstorg', email: 'new@mail.com', country_code: 'BO', currency: 'BOB',
      inventory_active: true }
    }

    let(:country) { OrgCountry.first }

    it "creates a new organisation" do
      org = Organisation.new(org_params)

      org.save.should eq(true)
    end

    it "inventory_active" do
      org = Organisation.new(org_params)

      org.save.should eq(true)
      org.inventory_active.should eq(true)
      org.should be_persisted

      org.inventory_active = false
      org.attributes = {country_code: 'BO', currency: 'BOB'}

      org.save.should eq(true)
      org.inventory_active.should eq(false)
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

  context 'due Dates' do
    it "#dued_on?" do
      org = Organisation.new(due_on: Date.today - 1.days)

      expect(org).to be_dued_on
    end

    it "#dued_with_extension?" do
      org = Organisation.new(due_on: Date.today - 5.days)

      expect(org).to be_dued_with_extension

      org.due_on = Date.today + 1.day

      expect(org).not_to be_dued_with_extension
    end
  end
end
