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

  context 'change currency' do
    let(:contact) { build :contact, id: 1 }
    let(:user) { build :user, id: 1 }

    before(:each) do
      contact.stub(save: true)
      UserSession.user = user
    end

    it "update currency" do
      i = Income.new_income(currency: 'BOB', total: 140, exchange_rate: 1, date: Date.today, contact_id: contact.id)
      i.stub(contact: contact, name: 'I-0001')

      i.save.should be_true

      i.attributes = {currency: 'USD', exchange_rate: 7, total: 20}
      i.save.should be_true

      i.stub(ledgers: [build(:account_ledger)])

      i.attributes = {currency: 'BOB', exchange_rate: 1, total: 140 }

      i.save.should be_false
      i.errors[:currency].should_not be_blank

      i.attributes = {currency: 'USD', exchange_rate: 1, total: 30 }
      i.save.should be_true
    end
  end

  describe "#null!" do
    let(:details) {
      [{item_id: 1, quantity: 10, price: 10, balance: 10},
       {item_id: 2, quantity: 10, price: 20.5, balance: 10}]
    }

    before(:each) do
      IncomeDetail.any_instance.stub(valid?: true)
      ExpenseDetail.any_instance.stub(valid?: true)
      Income.any_instance.stub(valid?: true)
      Expense.any_instance.stub(valid?: true)
    end

    let(:contact) { build :contact }
    let(:income) {
      i = Income.new_income(date: Date.today,
        income_details_attributes: details, state: 'approved')
      i.stub(contact: contact)
      i.save(validate: false)
      i
    }
    let(:expense) {
      e = Expense.new_expense(date: Date.today,
          expense_details_attributes: details, state: 'approved')
      e.stub(contact: contact)
      e.save(validate: false)
      e
    }

    it "#null! Income" do
      income.should be_is_approved
      income.should be_persisted

      det = income.income_details[0]
      det.balance = 5
      det.save.should be_true


      # Can't null
      income.reload
      income.null!.should be_nil
      income.should be_is_approved

      # Update balance
      det = IncomeDetail.find(det.id)
      det.balance = 10
      det.save.should be_true

      # Allow null
      income.reload
      income.null!.should be_true
      income.should be_is_nulled
    end

    it "#null! Expense" do
      expense.should be_is_approved
      expense.should be_persisted

      det = expense.expense_details[0]
      det.balance = 5
      det.save.should be_true


      # Can't null
      expense.reload
      expense.null!.should be_nil
      expense.should be_is_approved

      # Update balance
      det = ExpenseDetail.find(det.id)
      det.balance = 10
      det.save.should be_true

      # Allow null
      expense.reload
      expense.null!.should be_true
      expense.should be_is_nulled
    end
  end
end
