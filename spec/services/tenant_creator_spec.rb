require 'spec_helper'

describe TenantCreator do
  let(:tenant) { 'bonsaierp' }
  let(:organisation) { build(:organisation, id: 1, tenant: tenant) }

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  context "Initialize" do
    it {  TenantCreator.new(organisation) }
    it "error when bad name" do
      expect { TenantCreator.new('!-') }.to raise_error ArgumentError
    end
  end

  context "Create tenant" do
    let(:tc) { TenantCreator.new(organisation) }
    let(:conf) { ActiveRecord::Base.connection_config }

    before(:each) do
      UserSession.user = build :user, id: 1
    end

    it "has the correct config" do
      [:username, :database, :host, :password].each do |attr|
        conf[attr].should eq(tc.send(attr))
      end
    end

    it "creates a new schema with all tables" do
      tc.create_tenant.should be_true

      PgTools.should be_schema_exists(tc.tenant)

      PgTools.change_schema tc.tenant
      Unit.count.should > 0

      # Migrations are stored on public.schema_migrations
      #res = PgTools.execute "SELECT * FROM #{tc.tenant}.schema_migrations"
      #res.count.should > 0

      s = Store.first
      s.name.should eq('Almacen inicial')

      c = Cash.first
      c.name.should eq('Caja inicial')
      c.address.should be_blank

      t = Tax.first
      expect(t.name).to eq('IVA')
      t.percentage.should == 13.0
    end

    after(:all) do
      PgTools.drop_schema tenant if PgTools.schema_exists?(tenant)
      DatabaseCleaner.strategy = :transaction
    end
  end
end
