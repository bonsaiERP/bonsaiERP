require 'spec_helper'

describe TenantCreator do
  let(:tenant) { 'bonsaierp' }
  let(:organisation) { create(:organisation, id: 1, tenant: tenant) }

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  after(:all) do
    PgTools.drop_schema tenant if PgTools.schema_exists?('bonsaierp')
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation, { except: %w(schema_migrations) })

    sql = <<-SQL
INSERT INTO public.schema_migrations (version) VALUES
#{ActiveRecord::Migrator.migrations('db/migrate').map {|v| "('#{v.version}')" }.join(', ')}
    SQL

    #PgTools.execute sql
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

    # UserSession.user = User.first
    # org = Organisation.new(tenant: 'jeje', currency: 'BOB')
    # tc = TenantCreator.new(org)
    # tc.create_tenant

    it "creates a new schema with all tables" do
      expect(organisation.due_on).to be_nil
      expect(organisation.plan).to eq('2users')
      expect(tc.create_tenant).to eq(true)
      expect(PgTools).to be_schema_exists(tc.tenant)

      PgTools.change_schema tc.tenant
      Unit.count.should > 0

      # Migrations are stored on public.schema_migrations
      #res = PgTools.execute "SELECT * FROM #{tc.tenant}.schema_migrations"
      #res.count.should > 0
      #res = PgTools.execute("select count(*) from #{tc.tenant}.units")
      #res.values[0][0].to_i.should eq(6)

      s = Store.first
      s.name.should eq('Almacen inicial')

      c = Cash.first
      c.name.should eq('Caja inicial')
      c.address.should be_blank

      t = Tax.first
      expect(t.name).to eq('IVA')
      t.percentage.should == 13.0
      expect(organisation.due_on).to be_present
      expect(organisation.due_on).to eq(15.days.from_now.to_date)
    end


  end
end
