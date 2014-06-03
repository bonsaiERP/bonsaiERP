require 'spec_helper'

describe Link do
  it { should belong_to(:organisation) }
  it { should belong_to(:user) }
  it { should validate_presence_of(:role) }
  it { should validate_presence_of(:organisation_id) }

  context 'scopes'  do
    it "::org_links" do
      sql = Link.org_links(2).to_sql
      expect(sql).to match(/"links"."organisation_id" = 2/)
    end

    it "::active" do
      sql = Link.active.to_sql
      expect(sql).to match(/"links"."active" = 't'/)
    end

    it "::auth" do
      sql = Link.auth("we").to_sql

      expect(sql).to match(/"links"."active" = 't'/)
      expect(sql).to match(/"links"."api_token" = 'we'/)
      expect(sql).to match(/JOIN "common"."users"/)
    end
  end
end
