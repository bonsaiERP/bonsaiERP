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
    it { should have_many(:income_details).order('id asc').with_foreign_key(:account_id).dependent(:destroy) }

    it { should have_many(:payments).conditions(operation: 'payin').class_name('AccountLedger').with_foreign_key(:account_id) }

    it { should have_many(:devolutions).conditions(operation: 'devout').class_name('AccountLedger').with_foreign_key(:account_id) }

    it { should have_many(:ledgers) }
    it { should have_many(:inventories) }
    # Validations
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:contact) }
    it { should validate_presence_of(:contact_id) }
    it { should have_valid(:state).when(*Income::STATES) }
    it { should_not have_valid(:state).when(nil, 'ja', 1) }

    it { should accept_nested_attributes_for(:income_details).allow_destroy(true) }

    # Intialize
    it "Initial values" do
      #should be_is_draft
      #should_not be_discounted
      #should_not be_delivered
      should_not be_devolution
      expect(subject.total).to eq(0.0)
      expect(subject.balance).to eq(0.0)
      #subject.original_total).to == 0.0
      #subject.balance_inventory).to == 0.0
    end

    it "alias" do
      inc  = Income.new
      expect(inc.income_details).to eq(inc.details)
    end
  end

  it "define_method check" do
    inc = Income.new

    Income::STATES.each do |state|
      inc.state = state
      expect(inc.send(:"is_#{state}?")).to eq(true)
    end
  end

  let(:user) { build :user, id: 10 }
  before(:each) do
    UserSession.user = user
  end

  context 'callbacks' do

    it "does not update contact to client" do
      contact.client = true
      expect(contact).to_not receive(:update_attribute).with(:client, true)
      i = Income.new(valid_attributes)
      i.tag_ids = [1, 2]

      expect(i.save).to eq(true)
    end
  end

  it "checks the states methods" do
    Income::STATES.each do |state|
      expect(Income.new(state: state).send(:"is_#{state}?")).to eq(true)
    end
  end

  it "sets the to_s method to :name, :ref_number" do
    i = Income.new(ref_number: 'I-0012')
    expect(i.ref_number).to eq('I-0012')
    expect(i.ref_number).to eq(i.to_s)
  end

  it "$get_ref_number" do
    y = Time.zone.now.year.to_s[2..4]
    ref_num = Income.get_ref_number
    expect(ref_num).to eq("I-#{y}-0001")

    Income.stub_chain(:order, :reverse_order, :limit, pluck: ["I-#{y}-0001"])

    expect(Income.get_ref_number).to eq("I-#{y}-0002")

    Time.zone.stub(now: Time.zone.parse('2009-12-31'))
    expect(Income.get_ref_number).to eq("I-09-0001")
  end

  context "set_state_by_balance!" do
    it "a draft income" do
      i = Income.new(total: 10, balance: 10)

      i.set_state_by_balance!

      expect(i.is_draft?).to eq(true)
    end

    it "a paid income" do
      i = Income.new(total: 10, balance: -0)

      i.set_state_by_balance!

      expect(i.is_paid?).to eq(true)
    end

    it "a negative balance" do
      i = Income.new(total: 10, balance: -0.01)

      i.set_state_by_balance!

      expect(i.is_paid?).to eq(true)
    end

    # Changes to the income, it was paid but can change because of
    # changes in total or made a devolution that changed balance
    it "a paid income changes to approved" do
      i = Income.new(total: 10, balance: 0)

      i.set_state_by_balance!

      expect(i.is_paid?).to eq(true)

      i.balance = 2
      i.set_state_by_balance!

      expect(i.is_approved?).to eq(true)
    end

    it "does not set state if it has state" do
      i = Income.new(balance: 10, total:10)
      i.state = 'approved'

      expect(i.is_approved?).to eq(true)

      i.set_state_by_balance!

      expect(i.is_approved?).to eq(true)
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
    expect(i.subtotal).to eq(17.0)
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

    attrs.except(:approver_datetime).each do |k, v|
      expect(i.send(k)).to eq(v)
    end

    expect(i.approver_datetime.to_s).to eq(t.to_s)
  end

  context "approve!" do
    before do
      UserSession.user = build :user, id: 11
    end

    subject { Income.new(state: 'draft') }

    it "Changes" do
      i = subject
      expect(i.is_draft?).to eq(true)
      expect(i.approver_id).to be_blank
      expect(i.approver_datetime).to be_blank
      expect(i.due_date).to be_blank
      i.approve!

      expect(i.is_approved?).to eq(true)
      expect(i.approver_id).to eq(11)
      expect(i.approver_datetime.kind_of?(Time)).to eq(true)
      expect(i.due_date).to_not be_blank
    end

    it "only set the approve when it's draft" do
      i = subject
      i.state = 'paid'
      expect(i.is_paid?).to eq(true)
      i.approve!

      expect(i.is_paid?).to eq(true)
      expect(i.approver_id).to eq(nil)
    end
  end

  it "can receive a block to set certain arguments" do
    inc = Income.new(id: 1, total: 10, balance: 10)
    expect(inc.id).to eq(1)

    inc = Income.new(total: 10, balance: 10) {|e| e.id = 10}

    expect(inc.id).to eq(10)
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
      expect(inc.save).to eq(true)

      expect(inc.nuller_id).to be_blank

      expect(inc.null!).to eq(true)

      expect(inc.is_nulled?).to eq(true)
      expect(inc.nuller_id).to eq(15)
      expect(inc.nuller_datetime.kind_of?(Time)).to eq(true)
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
      expect(inc.save).to eq(true)

      expect(inc.details.size).to eq(2)
      det = inc.details[0]
      det.balance = 5
      expect(det.save).to eq(true)

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }


      expect(inc.details[0].marked_for_destruction?).to eq(true)

      expect(inc.save).to eq(false)
      expect(inc.details[0].marked_for_destruction?).to eq(false)
      expect(inc.details[0].errors[:item_id]).to eq([I18n.t('errors.messages.movement_details.not_destroy')])

      det = inc.details[0]
      det.balance = 10
      expect(det.save).to eq(true)

      inc = Income.find(inc.id)
      inc.attributes = {income_details_attributes: [{id: det.id, item_id: 1, price: 20, quantity: 10, "_destroy" => "1"}] }

      expect(inc.save).to eq(true)
      expect(inc.details.size).to eq(1)
      expect(inc.details.map(&:item_id)).to eq([2])
    end
  end

  describe 'scopes' do

    subject { Income }

    it "::pendent" do
      sql = <<-SQL
SELECT \"accounts\".* FROM \"accounts\"  WHERE \"accounts\".\"type\" IN ('Income') AND \"accounts\".\"state\" IN ('approved', 'paid') AND (\"accounts\".\"amount\" != 0)
      SQL

      expect(subject.pendent.to_sql.squish).to eq(sql.squish)
    end

    it "::like" do
      sql = <<-SQL
 SELECT "accounts".* FROM "accounts" WHERE "accounts"."type" IN ('Income') AND ("accounts"."name" ILIKE '%a%' OR "accounts"."description" ILIKE '%a%')
      SQL

      expect(subject.like('a').to_sql.squish).to eq(sql.squish)
    end

    it "::due" do
      expect(subject.due.to_sql).to match(
      /"accounts"."state" = 'approved' AND \(accounts.due_date < '#{Date.today}'\)/)
    end
  end
end
