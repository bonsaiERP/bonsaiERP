require 'spec_helper'

describe TenantCreator do
  let(:tenant) { 'tenant1' }

  context "Initialize" do
    it {  TenantCreator.new(tenant) }
    it "error when bad name" do
      expect { TenantCreator.new('!-') }.to raise_error ArgumentError
    end
  end

  context "Create tenant" do
    let(:t) { TenantCreator.new(tenant) }
    let(:conf) { ActiveRecord::Base.connection_config }

    it "has the correct config" do
      [:username, :database, :host, :password].each do |attr|
        conf[attr].should eq(t.send(attr))
      end
    end

    it "creates a new schema with all tables" do
      t.create_tenant.should be_true

      PgTools.should be_schema_exists(t.tenant)

      PgTools.change_schema t.tenant
      Account.count.should eq(0)
      AccountType.count.should > 0
      Unit.count.should > 0
    end

    after(:each) do
      PgTools.drop_schema tenant if PgTools.schema_exists?(tenant)
    end
  end
end
