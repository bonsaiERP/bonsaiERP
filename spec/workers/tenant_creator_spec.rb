require 'spec_helper'

describe TenantCreator do
  let(:tenant) { 'bonsaierp' }
  let(:organisation) { build(:organisation, id: 1, tenant: tenant) }

  context "Initialize" do
    it {  TenantCreator.new(organisation) }
    it "error when bad name" do
      expect { TenantCreator.new('!-') }.to raise_error ArgumentError
    end
  end

  context "Create tenant" do
    let(:t) { TenantCreator.new(organisation) }
    let(:conf) { ActiveRecord::Base.connection_config }

    before(:each) do
      UserSession.user = build :user, id: 1
    end

    it "has the correct config" do
      [:username, :database, :host, :password].each do |attr|
        conf[attr].should eq(t.send(attr))
      end
    end

    it "creates a new schema with all tables" do
      t.create_tenant.should be_true

      PgTools.should be_schema_exists(t.tenant)

      PgTools.change_schema t.tenant
      Account.count.should eq(1)
      Unit.count.should > 0

      res = PgTools.execute "SELECT * FROM #{t.tenant}.schema_migrations"
      res.count.should > 0

      s = Store.first
      s.name.should eq('Almacen inicial')

      c = Cash.first
      c.name.should eq('Caja inicial')
      c.address.should be_blank

      t = Tax.first
      expect(t.name).to eq('IVA')
      t.percentage.should == 13.0
    end

    after(:each) do
      PgTools.drop_schema tenant if PgTools.schema_exists?(tenant)
    end
  end
end
