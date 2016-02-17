require 'spec_helper'

describe Expense do
  let(:organisation) { build :organisation, id: 1 }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.organisation = organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    { active: nil, bill_number: "56498797", contact: contact, state: 'draft',
      exchange_rate: 1, currency: 'BOB', date: '2011-01-24', due_date: '2011-01-24',
      description: "Esto es una prueba",
      ref_number: "987654"
    }
  }


  it "define_method check" do
    ex = Expense.new

    Expense::STATES.each do |state|
      ex.state = state
      ex.should send(:"be_is_#{state}")
    end
  end

  context 'Relationships, Validations' do
    subject { Expense.new }

    # Relationships
    it { should belong_to(:contact) }
    it { should belong_to(:project) }
    it { should have_many(:expense_details) }
    it { should have_many(:payments) }
    it { should have_many(:devolutions) }
    it { should have_many(:inventories) }
    # Validations
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:contact) }
    it { should validate_presence_of(:contact_id) }
    it { should have_valid(:state).when(*Expense::STATES) }
    it { should_not have_valid(:state).when(nil, 'ja', 1) }

    it "initializes" do
      #should be_is_draft
      #should_not be_discounted
      should_not be_delivered
      should_not be_devolution
      subject.total.should == 0.0
      subject.balance.should == 0.0
      #subject.original_total.should == 0.0
      #subject.balance_inventory.should == 0.0
      #subject.ref_number.should =~ /E-\d{2}-\d{4}/
    end
  end

  let(:user) { build :user, id: 10 }
  before(:each) do
    UserSession.user = user
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
    y = Time.zone.now.year.to_s[2..4]
    ref_num = Expense.get_ref_number
    ref_num.should eq("E-#{y}-0001")

    Expense.stub_chain(:order, :reverse_order, :limit, pluck: ["E-#{y}-0001"])

    Expense.get_ref_number.should eq("E-#{y}-0002")

    Time.zone.stub(now: Time.zone.parse('2009-12-31'))
    Expense.get_ref_number.should eq("E-09-0001")
  end

  context "set_state_by_balance!" do
    it "a draft expense" do
      e = Expense.new(total: 10, balance: 10)

      e.set_state_by_balance!

      e.should be_is_draft
    end

    it "a paid expense" do
      e = Expense.new(total: 10, balance: -0)

      e.set_state_by_balance!

      e.should be_is_paid
    end

    it "a negative balance" do
      e = Expense.new(total: 10, balance: -0.01)

      e.set_state_by_balance!

      e.should be_is_paid
    end

    # Changes to the expense, it was paid but can change because of
    # changes in total or made a devolution that changed balance
    it "a paid expense changes to approved" do
      e = Expense.new(total: 10, balance: 0)

      e.set_state_by_balance!

      e.should be_is_paid

      e.balance = 1
      e.set_state_by_balance!

      e.should be_is_approved
    end

    it "does not set state if it has state" do
      e = Expense.new(balance: 10, total:10)
      e.state = 'approved'

      e.should be_is_approved

      e.set_state_by_balance!

      e.should be_is_approved
    end
  end

  it "returns the subtotal from  details" do
    e = Expense.new(valid_attributes.merge(
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

    e = Expense.new(attrs)

    attrs.except(:approver_datetime).each do |k, v|
      e.send(k).should eq(v)
    end

    expect(attrs[:approver_datetime].to_s).to eq(t.to_s)
  end

  context "approve!" do
    before do
      UserSession.user = build :user, id: 11
    end

    subject { Expense.new(state: 'draft') }

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
      e.extras = { 'test' => 1 }
      e.approve!
      #e.extras.should eq({'test' => "1", delivered: true})

      e.should be_is_paid
      e.approver_id.should be_nil
    end
  end

  it "can receive a block to set certain arguments" do
    ex = Expense.new(id: 1, total: 10, balance: 10)

    ex.id.should eq(1)

    ex = Expense.new(total: 10, balance: 10) {|e| e.id = 10}

    ex.id.should eq(10)
  end

  context 'Null' do
    let(:user) { build :user, id: 15 }

    before(:each) do
      UserSession.user = user
    end

    it "#nulls" do
      exp = Expense.new(valid_attributes.merge(total: 100, amount: 100, state: 'approved'))
      exp.save.should eq(true)

      exp.nuller_id.should be_blank

      exp.null!.should eq(true)

      exp.should be_is_nulled
      exp.nuller_id.should eq(15)
      exp.nuller_datetime.should be_is_a(Time)
    end
  end

  context "destroy item" do
    before(:each) do
      ExpenseDetail.any_instance.stub(item: build(:item, for_sale: true))

      Expense.any_instance.stub(contact: build(:contact), set_supplier_and_expenses_status: true)
    end

    let(:attributes) {
      {
      contact_id: 1, date: Date.today, due_date: Date.today, ref_number: 'E-0001', currency: 'BOB', state: 'draft',
      expense_details_attributes: [
        {item_id: 1, price: 20, quantity: 10}, {item_id: 2, price: 20, quantity: 10}
      ]
      }
    }

    it "#destroy item" do
      exp = Expense.new(attributes)

      exp.save.should eq(true)

      expect(exp.details.size).to eq(2)
      det = exp.details[0]
      det.balance = 5
      expect(det.save).to eq(true)

      exp = Expense.find(exp.id)
      exp.attributes = {expense_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }


      exp.details[0].should be_marked_for_destruction

      expect(exp.save).to eq(false)
      exp.details[0].should_not be_marked_for_destruction
      exp.details[0].errors[:item_id].should eq([I18n.t('errors.messages.movement_details.not_destroy')])

      det = exp.details[0]
      det.balance = 10
      expect(det.save).to eq(true)

      exp = Expense.find(exp.id)
      exp.attributes = {expense_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }

      expect(exp.save).to eq(true)
      expect(exp.details.size).to eq(1)
      expect(exp.details.map(&:item_id)).to eq([2])
    end
  end

  describe 'scopes' do
    subject { Expense }

    it "::pendent" do
      sql = <<-SQL
SELECT \"accounts\".* FROM \"accounts\"  WHERE \"accounts\".\"type\" IN ('Expense') AND \"accounts\".\"state\" IN ('approved', 'paid') AND (\"accounts\".\"amount\" != 0)
      SQL

      expect(subject.pendent.to_sql.squish).to eq(sql.squish)
    end

    it "::like" do
      sql = <<-SQL
 SELECT "accounts".* FROM "accounts" WHERE "accounts"."type" IN ('Expense') AND ("accounts"."name" ILIKE '%a%' OR "accounts"."description" ILIKE '%a%')
      SQL

      expect(subject.like('a').to_sql.squish).to eq(sql.squish)
    end

    it "::due" do
      expect(subject.due.to_sql).to match(
      /"accounts"."state" = 'approved' AND \(accounts.due_date < '#{Date.today}'\)/)
    end
  end

end
