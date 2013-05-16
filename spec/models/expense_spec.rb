require 'spec_helper'

describe Expense do
  let(:organisation) { build :organisation, id: 1 }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.organisation = organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    {active: nil, bill_number: "56498797", contact: contact,
      exchange_rate: 1, currency: 'BOB', date: '2011-01-24',
      description: "Esto es una prueba",  
      ref_number: "987654", state: 'draft'
    }
  }

  it "define_method check" do
    ex = Expense.new_expense

    Expense::STATES.each do |state|
      ex.state = state
      ex.should send(:"be_is_#{state}")
    end
  end

  context 'Relationships, Validations' do
    subject { Expense.new_expense }

    # Relationships
    it { should belong_to(:contact) }
    it { should belong_to(:project) }
    it { should have_one(:transaction) }
    it { should have_many(:expense_details) }
    it { should have_many(:payments) }
    it { should have_many(:interests) }
    it { should have_many(:transaction_histories) }
    # Validations
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:contact) }
    it { should validate_presence_of(:contact_id) }
    it { should have_valid(:state).when(*Expense::STATES) }
    it { should_not have_valid(:state).when(nil, 'ja', 1) }

    it "initializes" do
      should be_is_draft
      should_not be_discounted
      should_not be_delivered
      should_not be_devolution
      subject.total.should == 0.0
      subject.balance.should == 0.0
      subject.original_total.should == 0.0
      subject.balance_inventory.should == 0.0
    end
  end

  context 'callbacks' do
    it 'check callback' do
      contact.should_receive(:supplier=).with(true)

      i = Expense.new_expense(valid_attributes)

      i.save.should be_true
    end

    it "does not update contact to supplier" do
      contact.supplier = true
      contact.should_not_receive(:update_attribute).with(:supplier, true)
      e = Expense.new_expense(valid_attributes)

      e.save.should be_true
    end
  end

  it "checks the states methods" do
    Expense::STATES.each do |state|
      Expense.new(state: state).should send(:"be_is_#{state}")
    end
  end

  it "sets the to_s method to :name, :ref_number" do
    e = Expense.new(ref_number: 'I-0012')
    e.ref_number.should eq('I-0012')
    e.ref_number.should eq(e.to_s)
  end

  it "gets the latest ref_number" do
    y = Date.today.year.to_s[2..4]
    ref_num = Expense.get_ref_number
    ref_num.should eq("E-#{y}-0001")

    Expense.stub_chain(:order, :limit, pluck: ["E-#{y}-0001"])

    Expense.get_ref_number.should eq("E-#{y}-0002")

    Date.stub_chain(:today, year: 2099)
    Expense.get_ref_number.should eq("E-99-0001")
  end

  context "set_state_by_balance!" do
    it "a draft expense" do
      e = Expense.new_expense(total: 10, balance: 10)

      e.set_state_by_balance!

      e.should be_is_draft
    end

    it "a paid expense" do
      e = Expense.new_expense(total: 10, balance: -0)

      e.set_state_by_balance!

      e.should be_is_paid
    end

    it "a negative balance" do
      e = Expense.new_expense(total: 10, balance: -0.01)

      e.set_state_by_balance!

      e.should be_is_paid
    end

    # Changes to the expense, it was paid but can change because of
    # changes in total or made a devolution that changed balance
    it "a paid expense changes to approved" do
      e = Expense.new_expense(total: 10, balance: 0)

      e.set_state_by_balance!

      e.should be_is_paid

      e.balance = 1
      e.set_state_by_balance!

      e.should be_is_approved
    end

    it "does not set state if it has state" do
      e = Expense.new_expense(balance: 10, total:10)
      e.state = 'approved'

      e.should be_is_approved

      e.set_state_by_balance!

      e.should be_is_approved
    end
  end

  it "returns the subtotal from  details" do
    e = Expense.new_expense(valid_attributes.merge(
      {expense_details_attributes: [
        {item_id: 1, price: 10, quantity: 1},
        {item_id: 2, price: 3.5, quantity: 2}
      ]
    }
    ))

    e.subtotal.should == 17.0
  end

  it "checks the methods approver, nuller, creator" do
    t = Time.now
    d = Date.today
    attrs = {
      balance: 10, bill_number: '123',
      gross_total: 10, original_total: 10, balance_inventory: 10,
      due_date: d, creator_id: 1, approver_id: 2,
      nuller_id: 3, null_reason: 'Null', approver_datetime: t,
      delivered: true, devolution: true
    }

    e = Expense.new_expense(attrs)

    attrs.each do |k, v|
      e.send(k).should eq(v)
    end
  end

  context "approve!" do
    before do
      UserSession.user = build :user, id: 11
    end

    subject { Expense.new_expense }

    it "Changes" do
      e = subject
      e.should be_is_draft
      e.approver_id.should be_blank
      e.approver_datetime.should be_blank
      e.approve!

      e.should be_is_approved
      e.approver_id.should eq(11)
      e.approver_datetime.should be_is_a(Time)
    end

    it "only set the approve when it's draft" do
      e = subject
      e.state = 'paid'
      e.should be_is_paid
      e.approve!

      e.should be_is_paid
      e.approver_id.should be_nil
    end
  end

  it "can receive a block to set certain arguments" do
    ex = Expense.new_expense(id: 10, total: 10, balance: 10)

    ex.id.should be_nil

    ex = Expense.new_expense(total: 10, balance: 10) {|e| e.id = 10}

    ex.id.should eq(10)
  end

  context 'Contact callbacks' do
    let(:user) { build :user, id: 15 }

    before(:each) do
      UserSession.user = user
    end

    it "update#incomes_status" do
      exp = Expense.new_expense(valid_attributes.merge(state: 'approved', total: 10, amount: 5.0))

      exp.save.should be_true
      exp.should be_is_approved

      exp.contact.expenses_status.should eq({
        'TOTAL' => 5.0,
        'BOB' => 5.0
      })

      # New expense
      exp = Expense.new_expense(valid_attributes.merge(state: 'approved', total: 10, amount: 5.0, ref_number: 'I232483'))
      exp.save.should be_true

      exp.contact.expenses_status.should eq({
        'TOTAL' => 10.0,
        'BOB' => 10.0
      })

      exp = Expense.new_expense(valid_attributes.merge(state: 'approved', currency: 'USD', total: 20, amount: 3.3, exchange_rate: 7.0, ref_number: 'I2324839'))
      exp.save.should be_true
      exp.should be_is_approved

      exp.contact.expenses_status.should eq({
        'TOTAL' => (10 + 3.3 * 7).round(2),
        'BOB' => 10.0, 
        'USD' => 3.3
      })

      exp.amount = 20
      exp.save.should be_true

      exp.null!.should be_true
      exp.should be_is_nulled

      exp.contact.expenses_status.should eq({
        'TOTAL' => 10.0,
        'BOB' => 10.0
      })
    end
  end

  context 'Null' do
    let(:user) { build :user, id: 15 }

    before(:each) do
      UserSession.user = user
    end

    it "#nulls" do
      exp = Expense.new_expense(valid_attributes.merge(total: 100, amount: 100))
      exp.save.should be_true

      exp.nuller_id.should be_blank

      exp.null!.should be_true

      exp.should be_is_nulled
      exp.nuller_id.should eq(15)
      exp.nuller_datetime.should be_is_a(Time)
    end
  end

  context "deestroy item" do
    before(:each) do
      ExpenseDetail.any_instance.stub(item: stub(for_sale?: true))
      Expense.any_instance.stub(contact: true, set_supplier_and_expenses_status: true)
    end
    let(:attributes) {
      {
      contact_id: 1, date: Date.today, ref_number: 'E-0001', currency: 'BOB',
      expense_details_attributes: [
        {item_id: 1, price: 20, quantity: 10}, {item_id: 2, price: 20, quantity: 10}
      ]
      }
    }

    it "_destroy item" do
      exp = Expense.new_expense(attributes)
      exp.save.should be_true

      exp.items.should have(2).items
      det = exp.items[0]
      det.balance = 5
      det.save.should be_true

      exp = Expense.find(exp.id)
      exp.attributes = {expense_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }


      exp.items[0].should be_marked_for_destruction

      exp.save.should be_false
      exp.items[0].should_not be_marked_for_destruction
      exp.items[0].errors[:quantity].should eq([I18n.t('errors.messages.trasaction_details.not_destroy')])

      det = exp.items[0]
      det.balance = 10
      det.save.should be_true

      exp = Expense.find(exp.id)
      exp.attributes = {expense_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }

      exp.save.should be_true
      exp.items.should have(1).item
      exp.items.map(&:item_id).should eq([2])
    end
  end
end
