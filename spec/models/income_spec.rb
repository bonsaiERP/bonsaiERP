require 'spec_helper'

describe Income do
  let(:organisation) { build :organisation, id: 1, currency: 'BOB' }
  let(:contact) { build :contact, id: 10 }

  before(:each) do
    OrganisationSession.organisation = organisation
    Contact.any_instance.stub(save: true)
  end

  let(:valid_attributes) {
    {active: nil, bill_number: "56498797", contact: contact,
      exchange_rate: 1, currency: 'BOB', date: '2011-01-24', due_date: '2011-01-24',
      description: "Esto es una prueba", amount: 1,
      ref_number: "987654", state: 'draft'
    }
  }

  context 'Relationships, Validations' do

    # Relationships
    it { should belong_to(:contact) }
    it { should belong_to(:project) }
    it { should have_many(:income_details) }
    it { should have_many(:payments) }
    it { should have_many(:devolutions) }
    it { should have_many(:ledgers) }
    it { should have_many(:inventories) }
    # Validations
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:contact) }
    it { should validate_presence_of(:contact_id) }
    it { should have_valid(:state).when(*Income::STATES) }
    it { should_not have_valid(:state).when(nil, 'ja', 1) }

    # Intialize
    it "Initial values" do
      #should be_is_draft
      #should_not be_discounted
      #should_not be_delivered
      should_not be_devolution
      subject.total.should == 0.0
      subject.balance.should == 0.0
      #subject.original_total.should == 0.0
      #subject.balance_inventory.should == 0.0
    end
  end

  it "define_method check" do
    inc = Income.new

    Income::STATES.each do |state|
      inc.state = state
      inc.should send(:"be_is_#{state}")
    end
  end

  let(:user) { build :user, id: 10 }
  before(:each) do
    UserSession.user = user
  end

  context 'callbacks' do
    it 'check callback' do
      i = Income.new(valid_attributes)

      i.should_receive(:symbolize_keys_extras)
      i.save.should be_true
    end

    it "does not update contact to client" do
      contact.client = true
      contact.should_not_receive(:update_attribute).with(:client, true)
      i = Income.new(valid_attributes)

      i.save.should be_true
    end
  end

  it "checks the states methods" do
    Income::STATES.each do |state|
      Income.new(state: state).should send(:"be_is_#{state}")
    end
  end

  it "sets the to_s method to :name, :ref_number" do
    i = Income.new(ref_number: 'I-0012')
    i.ref_number.should eq('I-0012')
    i.ref_number.should eq(i.to_s)
  end

  it "$get_ref_number" do
    y = Date.today.year.to_s[2..4]
    ref_num = Income.get_ref_number
    ref_num.should eq("I-#{y}-0001")

    Income.stub_chain(:order, :reverse_order, :limit, pluck: ["I-#{y}-0001"])

    Income.get_ref_number.should eq("I-#{y}-0002")

    Date.stub_chain(:today, year: 2099)
    Income.get_ref_number.should eq("I-99-0001")
  end

  context "set_state_by_balance!" do
    it "a draft income" do
      i = Income.new(total: 10, balance: 10)

      i.set_state_by_balance!

      i.should be_is_draft
    end

    it "a paid income" do
      i = Income.new(total: 10, balance: -0)

      i.set_state_by_balance!

      i.should be_is_paid
    end

    it "a negative balance" do
      i = Income.new(total: 10, balance: -0.01)

      i.set_state_by_balance!

      i.should be_is_paid
    end

    # Changes to the income, it was paid but can change because of
    # changes in total or made a devolution that changed balance
    it "a paid income changes to approved" do
      i = Income.new(total: 10, balance: 0)

      i.set_state_by_balance!

      i.should be_is_paid

      i.balance = 2
      i.set_state_by_balance!

      i.should be_is_approved
    end

    it "does not set state if it has state" do
      i = Income.new(balance: 10, total:10)
      i.state = 'approved'

      i.should be_is_approved

      i.set_state_by_balance!

      i.should be_is_approved
    end
  end

  it "returns the subtotal from  details" do
    i = Income.new(valid_attributes.merge(
      {income_details_attributes: [
        {item_id: 1, price: 10, quantity: 1},
        {item_id: 2, price: 3.5, quantity: 2}
      ]
    }
    ))
    i.subtotal.should == 17.0
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

    i = Income.new(attrs)

    attrs.each do |k, v|
      i.send(k).should eq(v)
    end
  end

  context "approve!" do
    before do
      UserSession.user = build :user, id: 11
    end

    subject { Income.new(state: 'draft') }

    it "Changes" do
      i = subject
      i.should be_is_draft
      i.approver_id.should be_blank
      i.approver_datetime.should be_blank
      i.due_date.should be_blank
      i.approve!

      i.should be_is_approved
      i.approver_id.should eq(11)
      i.approver_datetime.should be_is_a(Time)
      i.due_date.should_not be_blank
    end

    it "only set the approve when it's draft" do
      i = subject
      i.state = 'paid'
      i.should be_is_paid
      i.approve!

      i.should be_is_paid
      i.approver_id.should be_nil
    end
  end

  it "can receive a block to set certain arguments" do
    inc = Income.new(id: 1, total: 10, balance: 10)
    inc.id.should eq(1)

    inc = Income.new(total: 10, balance: 10) {|e| e.id = 10}

    inc.id.should eq(10)
  end

  context 'Contact callbacks' do
    let(:user) { build :user, id: 15 }

    before(:each) do
      UserSession.user = user
    end

  end

  context 'Null' do
    let(:user) { build :user, id: 15 }

    before(:each) do
      UserSession.user = user
    end

    it "#nulls" do
      inc = Income.new(valid_attributes.merge(total: 100, amount: 100, state: 'approved'))
      inc.save.should be_true

      inc.nuller_id.should be_blank

      inc.null!.should be_true

      inc.should be_is_nulled
      inc.nuller_id.should eq(15)
      inc.nuller_datetime.should be_is_a(Time)
    end
  end

  context "deestroy item" do
    before(:each) do
      IncomeDetail.any_instance.stub(item: build(:item, for_sale: true))
      Income.any_instance.stub(contact: build(:contact), set_client_and_incomes_status: true)
    end
    let(:attributes) {
      {
      contact_id: 1, date: Date.today, due_date: Date.today, ref_number: 'I-0001', currency: 'BOB', state: 'draft',
      income_details_attributes: [
        {item_id: 1, price: 20, quantity: 10}, {item_id: 2, price: 20, quantity: 10}
      ]
      }
    }

    it "_destroy item" do
      inc = Income.new(attributes)
      inc.save.should be_true

      inc.details.should have(2).items
      det = inc.details[0]
      det.balance = 5
      det.save.should be_true

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }


      inc.details[0].should be_marked_for_destruction

      inc.save.should be_false
      inc.details[0].should_not be_marked_for_destruction
      inc.details[0].errors[:item_id].should eq([I18n.t('errors.messages.movement_details.not_destroy')])

      det = inc.details[0]
      det.balance = 10
      det.save.should be_true

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }

      inc.save.should be_true
      inc.details.should have(1).item
      inc.details.map(&:item_id).should eq([2])
    end
  end

  describe 'scopes' do

    it "::pendent" do
      sql = <<-SQL
SELECT \"accounts\".* FROM \"accounts\"  WHERE \"accounts\".\"type\" IN ('Income') AND \"accounts\".\"state\" IN ('approved', 'paid') AND (\"accounts\".\"amount\" != 0)
      SQL

      expect(Income.pendent.to_sql.squish).to eq(sql.squish)
    end

    it "::like" do
      sql = <<-SQL
 SELECT "accounts".* FROM "accounts" WHERE "accounts"."type" IN ('Income') AND (("accounts"."name" ILIKE '%a%' OR "accounts"."description" ILIKE '%a%'))
      SQL

      expect(Income.like('a').to_sql.squish).to eq(sql.squish)
    end
  end
end
