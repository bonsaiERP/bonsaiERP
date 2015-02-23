# encoding: utf-8
require 'spec_helper'

describe Account do

  it { should belong_to(:updater).class_name('User') }
  #
  it { should belong_to(:contact) }
  it { should have_many(:account_ledgers) }


  it { should have_valid(:currency).when('BOB', 'EUR') }
  it { should_not have_valid(:currency).when('BOBB', 'UUUU') }
  it { should have_valid(:amount).when(10, 0.0, -10.0) }
  it { should_not have_valid(:amount).when(nil, '') }

  it { should validate_uniqueness_of(:name) }

  before :each do
    UserSession.user = build :user, id: 1
  end

  let(:valid_params) do
    {name: 'account1', currency: 'BOB', amount: 100, state: 'new'}
  end

  context 'scopes' do
    it "::to_pay" do
      ac = Account.active.new
      ac.should be_active
    end

    it "::money" do
      ac = Account.money
      #expect(ac.type).to eq(["Bank", "Cash"])
      expect(ac.to_sql).to match(/'Bank', 'Cash'/)

      ac = Account.active.money
      expect(ac.to_sql).to match(/"accounts"."active" = 't' AND "accounts"."type" IN \('Bank', 'Cash'\)/)
    end
  end

  it 'should be created' do
    Account.create!(valid_params)
  end

  context 'tags' do
    before(:each) do
      Tag.create(name: 'tag1', bgcolor: '#efefef')
      Tag.create(name: 'tag2', bgcolor: '#efefef')
    end

    let (:tag_ids) { Tag.select("id").pluck(:id) }

    it "valid_tags" do
      a = Account.new(valid_params.merge(tag_ids: [tag_ids.first]))
      a.save.should eq(true)
      a.tag_ids.should eq([tag_ids.first])

      t_ids = tag_ids + [100000, 99999999]
      a.tag_ids = t_ids

      expect(a.tag_ids.size).to eq(4)

      a.save.should eq(true)

      expect(a.tag_ids).to eq(tag_ids)
      expect(a.tag_ids.size).to eq(2)

      expect(a.updater_id).to eq(1)

      a.tag_ids = [1231231232, 23232]
      a.save.should eq(true)

      expect(a.tag_ids).to eq([])
      expect(a.tag_ids.size).to eq(0)
    end

    it "scopes" do
      Tag.create!(name: 'tag3', bgcolor: '#efefef')
      Account.create!(valid_params.merge(tag_ids: [tag_ids.first]))
      Account.create!(valid_params.merge(name: 'other name', tag_ids: tag_ids))

      expect(Account.any_tags(*tag_ids).count).to eq(2)

      expect(Account.all_tags(*tag_ids).count).to eq(1)
    end
  end
end
