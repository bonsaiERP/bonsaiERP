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
      u = create :user
      l = Link.create! user_id: u.id, active: true, api_token: 'uno', organisation_id: 1, role: 'admin', tenant: 'bon'
      l = Link.auth('uno', 'bon')

      expect(l).to be_present
      expect(l).to be_active
      expect(l.user).to be_is_a(User)
    end
  end
end
