require 'spec_helper'
=begin
describe Loan do
  it{ should have_valid(:total).when(1, 100) }
  it{ should_not have_valid(:total).when(0, -100) }

  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100,
      interests: 10
    }
  }

  it { should have_one(:loan_extra) }

  before(:each) do
    UserSession.user = build(:user, id: 1)
  end

  describe 'initialization' do
    it "#attributes" do
      l = Loan.new
      keys = l.attributes.keys

      keys.should be_include('id')
      keys.should be_include('name')
      keys.should be_include('step')
      keys.should be_include('total')
      keys.should be_include('interests')
    end

    it "initializes all attributes" do
      l = Loan.new(attributes)
      expect(l.name).to eq('P-0001')
      l.total.should == 100
      l.amount.should == 100
      l.interests.should == 10
    end

    it "create" do
      l = Loan.create!(attributes)
      #Loan.create!(attributes.merge(name: 'P-0002'))

      l.attributes
      l.amount.should == 100

      l.amount = 50
      l.save.should be_true

      l = Loan.find l.id
      l.amount.should == 50
      #Loan.all.each do |l|
      #  puts l.amount
      #end
    end
  end
end
=end
