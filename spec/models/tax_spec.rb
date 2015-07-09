require 'spec_helper'

describe Tax do
  it { should have_many(:accounts) }
  it { should validate_uniqueness_of(:name) }
  it { should have_valid(:name).when('Tax 1', 'Tax with details') }
  it { should_not have_valid(:name).when('', 'T' * 21) }


  it { should have_valid(:percentage).when(0, 1.2, 10.2, 100) }
  it { should_not have_valid(:percentage).when(-1.2, 1000) }

  it "#to_s" do
    t = Tax.new(name: 'IVA', percentage: 13.0)
    t.to_s.should eq('IVA (13%)')

    t.percentage = 1.5
    t.to_s.should eq('IVA (1.5%)')

    t.percentage = 2.33
    t.to_s.should eq('IVA (2.33%)')
  end

  it "does not destroy" do
    t = Tax.new(name: 'IVA', percentage: 13.0)
    t.destroy.destroyed?.should eq(true)

    t = Tax.new(name: 'IVA', percentage: 13.0)
    t.stub(accounts: [Account.new])

    expect(t.destroy).to eq(false)
  end
end
