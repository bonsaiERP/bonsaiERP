require 'spec_helper'

describe UserWithRole do
  it "expects user" do
    expect { UserWithRole.new(nil, nil)}.to raise_error
  end

  it "expects organisation" do
    u = build :user
    expect { UserWithRole.new(u, u)}.to raise_error
  end

  let(:link) { build(:link, master_account: true, role: 'admin') }
  let(:org) { build(:organisation, id: 1) }
  let(:user) { build :user, id: 10 }

  describe 'Check roles' do

    before(:each) do
      user.stub_chain(:links, org_links: [link])
    end

    it "admin master account" do
      us = UserWithRole.new(user, org)
      us.should be_is_admin
      us.should be_master_account
    end

    it "group not master_account" do
      link.role = 'group'
      link.master_account = false
      us = UserWithRole.new(user, org)
      us.should be_is_group
      us.should_not be_master_account
    end

    it "other not master_account" do
      link.role = 'other'
      link.master_account = false
      us = UserWithRole.new(user, org)
      us.should be_is_other
      us.should_not be_master_account
    end
  end

  it "nil link" do
    us = UserWithRole.new(user, org)
    us.link.should be_nil
  end
end
