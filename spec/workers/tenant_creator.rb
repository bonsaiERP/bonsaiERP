require 'spec_helper'

describe TenantCreator do
  let(:tenant_name) { 'tenant1' }

  context "Initialize" do
    it {  TenantCreator.new(tenant_name) }
    it "error when bad name" do
      expect { TenantCreator.new('!-') }.to raise_error ArgumentError
    end
  end

  context "Create tenant" do
    let(:tenant) { tenant = TenantCreator.new(tenant_name) }
    let(:conf) { ActiveRecord::Base.connection_config }

    it "has the correct config" do
      [:username, :database, :host, :password].each do |attr|
        conf[attr].should eq(tenant.send(attr))
      end
    end

    it "creates a new schema with all tables" do
      tenant.create_tenant.should be_true

      PgTools.should be_schema_exists(tenant.tenant)

      PgTools.change_schema tenant.tenant
      Account.count.should eq(0)
      AccountType.count.should > 0
      Unit.count.should > 0
    end

    after(:each) do
      PgTools.drop_schema tenant_name if PgTools.schema_exists?(tenant_name)
    end
  end
end
