require 'spec_helper'

describe Movement do

  it { should belong_to(:contact) }
  it { should belong_to(:project) }
  it { should belong_to(:tax) }


  before(:each) do
    UserSession.user = build :user, id: 10
  end

  context "#can_null?" do
    let(:subject) {
      m = Movement.new(amount: 100, state: 'draft')
      m.total =  100
      m
    }

    it { should be_is_draft }
    # draft
    it { should_not be_can_null }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:due_date) }

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
      m = Income.new(amount: 100, state: 'draft')
      m.total =  100
      m
    }

    it { should_not be_can_devolution }

    it "total == balance" do
      subject.state = 'approved'
      subject.should be_is_approved

      subject.should_not be_can_devolution
      subject.balance.should == subject.total
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
    i = Income.new(state: 'approved')
    i.should be_is_active

    i.state = 'paid'
    i.should be_is_active
  end

  it "#inventory" do
    e = Expense.new
    expect(e.inventory?).to be_false
  end

  it "due_date >= date" do
    today = Date.today
    i = Income.new date: today, due_date: today - 1.day

    i.should_not be_valid
    i.errors_on(:due_date).should eq([I18n.t('errors.messages.movement.greater_due_date')])
  end

  context 'change currency' do
    let(:contact) { build :contact, id: 1 }
    let(:user) { build :user, id: 1 }

    before(:each) do
      contact.stub(save: true)
      UserSession.user = user
    end

    it "update currency" do
      i = Income.new(currency: 'BOB', total: 140, exchange_rate: 1, date: Date.today, contact_id: contact.id, due_date: Date.today, state: 'draft')
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
      i = Income.new(date: Date.today,
        income_details_attributes: details, state: 'approved')
      i.stub(contact: contact)
      i.save(validate: false)
      i
    }
    let(:expense) {
      e = Expense.new(date: Date.today, due_date: Date.today,
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

    it "#attributes" do
      t = Time.zone.now
      c = build :contact, id: 1
      attrs = { bill_number: '123', gross_total: 100, original_total: 101,
                balance_inventory: 50, nuller_datetime: t, null_reason: 'No se',
                approver_datetime: t,
                discounted: false, devolution: false, inventory: true}
      d = Date.today
      m = Movement.new({
        currency: 'BOB', ref_number: 'Ref-001', date: d, due_date: d,
        contact_id: 1, state: 'draft'
      }.merge(attrs))
      m.stub(contact: c)
      m.save.should be_true

      m = Movement.find(m.id)
      at = m.attributes
      attrs.except(:nuller_datetime, :approver_datetime).each do |k, v|
        at.fetch(k.to_s).should eq(v)
      end

      m.nuller_datetime.should be_is_a(Time)
      m.approver_datetime.should be_is_a(Time)

      m.nuller_datetime.to_s.should eq(t.to_s)
      m.approver_datetime.to_s.should eq(t.to_s)

      m.inventory?.should be_true
      m.devolution?.should be_false
    end

  end

  it "#extras" do

    t = DateTime.now
    h = {
      devolution: true, delivered: true, discounted: true, inventory: false,
      gross_total: 12.3, original_total: 2.3, balance_inventory: 1.1,
      nuller_datetime: t, approver_datetime: t
    }


    m = Movement.new(extras: h)
    m.extras.keys.all? {|key| key.is_a?(String) }
    m.extras.values.all? {|val| val.is_a?(String) }

    h.except(:nuller_datetime, :approver_datetime).each do |key, val|
       m.send(key).should eq(val)
     end


     %i(nuller_datetime approver_datetime).each do |key|
       m.send(key).should be_is_a(Time)
     end

  end
end
