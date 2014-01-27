require 'spec_helper'

describe Loan do
  it { should have_valid(:total).when(1, 100) }
  it { should_not have_valid(:total).when(0, -100) }
  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:due_date) }
  it { should have_valid(:state).when(*Loan::STATES) }
  it { should_not have_valid(:state).when('a', nil) }

  it { should have_many(:histories) }

  let(:attributes) {
    today = Date.today
    {
      name: 'P-0001', currency: 'BOB', date: today,
      due_date: today + 10.days, total: 100, amount: 100,
      interests: 10, contact_id: 1, state: 'approved'
    }
  }

  it "is_approved?" do
    l = Loan.new
    l.state = 'approved'
    l.should be_is_approved
    l.state = 'paid'
    l.should be_is_paid
    l.state = 'nulled'
    l.should be_is_nulled
  end

  it "#valid_due_date" do
    l = Loan.new(attributes)
    l.stub(contact: build(:contact))

    l.due_date = l.date - 1.day

    expect(l).to be_invalid

    l.due_date = l.date

    expect(l).to be_valid
  end


  before(:each) do
    UserSession.user = build(:user, id: 1)
  end

  describe 'initialization' do
    it "#attributes" do
      l = Loan.new
      keys = l.attributes.keys

      keys.should be_include('id')
      keys.should be_include('name')
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

    #it "create" do
    #  Loan.any_instance.stub(contact: build(:contact))

    #  l = Loan.new(attributes)
    #  l.save.should be_true
    #  #Loan.create!(attributes.merge(name: 'P-0002'))

    #  l.attributes
    #  l.amount.should == 100

    #  l.amount = 50
    #  l.save.should be_true

    #  l = Loan.find l.id
    #  l.amount.should == 50
    #  #Loan.all.each do |l|
    #  #  puts l.amount
    #  #end
    #end
  end
end
