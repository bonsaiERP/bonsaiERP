require 'spec_helper'

describe Tag do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should have_valid(:name).when('uno', 'buena cosa', 'niño 1') }
  it { should_not have_valid(:name).when('', 'uno!', 'aa', 'uno, a', '   ', 'a' * 21) }

  it { should have_valid(:bgcolor).when('#fffaba', '#FFFABA', '#000000') }
  it { should_not have_valid(:bgcolor).when('#fffaba3', '000000','#0d0d0g') }

  it "#to_s" do
    tag = Tag.new(name: 'test')
    expect(tag.to_s).to eq('test')
    expect(tag.label).to eq('test')
  end

  context "update_models" do
    it "udpates" do
      user = build :user, id: 1
      UserSession.user = user

      a1 = Account.create!(name: 'first', currency: 'BOB')
      a2 = Account.create!(name: 'second', currency: 'BOB')

      t1 = Tag.create!(name: 'tag1', bgcolor: '#ff0000')
      t2 = Tag.create!(name: 'tag2', bgcolor: '#efefef')
      tag_ids = [t1.id, t2.id]

      Tag.update_models({ids: [a1.id, a2.id], model: 'Account', tag_ids: tag_ids})

      expect(Account.all.map(&:tag_ids)).to eq([tag_ids, tag_ids])

      u = build :unit, id: 3
      i = build :item, unit_id: u.id
      i.stub(unit: u)
      i.save!

      Tag.update_models({ids: [i.id], model: 'Item', tag_ids: tag_ids})
      i = Item.find i.id

      expect( i.tag_ids ).to eq(tag_ids)
    end
  end
end
