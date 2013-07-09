require 'spec_helper'

describe Movement do

  context "#can_null?" do
    let(:subject) {
      m = Movement.new(amount: 100, state: 'draft')
      m.build_transaction
      m.total =  100
      m
    }

    it { should be_is_draft }
    # draft
    it { should_not be_can_null }

    it "can null" do
      subject.state = 'approved'
      subject.should be_can_null
    end

    it "diferent total" do
      subject.balance = 90

      subject.should_not be_can_null
    end

    it "pendent_ledgers" do
      subject.stub_chain(:ledgers, :pendent, empty?: false)

      subject.should_not be_can_null
    end

    it "is_nulled" do
      subject.state = 'nulled'

      subject.should_not be_can_null
    end

    # Can null
    it "approved" do
      subject.state = 'approved'
      subject.should be_is_approved

      subject.should be_can_null
    end
  end

  context "can_devolution?" do
    let(:subject) {
      m = Movement.new(amount: 100, state: 'draft')
      m.build_transaction
      m.total =  100
      m
    }

    it { should_not be_can_devolution }

    it "total == balance" do
      subject.state = 'approved'
      subject.should be_is_approved

      subject.should_not be_can_devolution
    end

    it "total > balance" do
      subject.state = 'approved'
      subject.should be_is_approved
      subject.balance = 90

      subject.should be_can_devolution
    end

    it "is_nulled?" do
      subject.state = 'nulled'
      subject.should be_is_nulled

      subject.should_not be_can_devolution
    end
  end

  it "#is_active?" do
    i = Income.new_income(state: 'approved')
    i.should be_is_active

    i.state = 'paid'
    i.should be_is_active
  end

  it "#no_inventory" do
    e = Expense.new_expense
    expect(e.no_inventory).to be_false
  end
end
