# encoding: utf-8
describe Incomes::Form do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { 490 }
  let(:details_total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:contact) { build :contact, id: 1 }
  let(:valid_params) { {
      date: Date.today, contact_id: 1, total: total,
      currency: 'BOB', bill_number: "I-0001", description: "New income description",
      income_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

  context "Initialization" do
    subject { Incomes::Form.new_income(valid_params) }

    it "income_details" do
      subject.income.should be_is_a(Income)
      subject.date.should be_is_a(Date)
      subject.currency.should eq('BOB')
      subject.direct_payment.should be_false
      subject.income.income_details.should have(2).items

      subject.income.income_details[0].item_id.should eq(details[0][:item_id])
      subject.income.income_details[0].description.should eq(details[0][:description])
      subject.income.income_details[0].price.should eq(details[0][:price])
      subject.income.income_details[0].quantity.should eq(details[0][:quantity])
      subject.income.income_details[1].item_id.should eq(details[1][:item_id])
      subject.should respond_to(:details)
      subject.should respond_to(:income_details)
      subject.should respond_to(:income_details_attributes)
      subject.should respond_to(:income_details_attributes=)
    end

    it "sets_defaults if nil" do
      is = Incomes::Form.new_income
      is.income.ref_number.should =~ /I-\d{2}-000\d/
      is.income.currency.should eq('BOB')
      is.income.date.should eq(Date.today)
    end
  end

  context "Validation" do
    it "#valid?" do
      is = Incomes::Form.new_income(account_to_id: 2, direct_payment: "1")

      is.should_not be_valid
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

      is = Incomes::Form.new_income(account_to_id: 2, direct_payment: "1", total: 150)
      is.details.should have(2).items
      is.details.map(&:quantity).should eq([1,1])
    end

    it "unique items" do
      is = Incomes::Form.new_income(income_details_attributes: [
        {item_id: 1, quantity: 10, price: 1}, {item_id: 2, quantity: 10, price: 3},
        {item_id: 1, quantity: 3, price: 5}
      ])
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])
      IncomeDetail.any_instance.stub(item: true)

      is.should_not be_valid
      is.errors[:base].should eq([I18n.t("errors.messages.item.repeated_items")])
      is.income.income_details[0].errors.should be_blank
      is.income.income_details[1].errors.should be_blank
      is.income.income_details[2].errors[:item_id].should eq([I18n.t("errors.messages.item.repeated")])
    end
  end

  context "Create a income with default data" do
    before(:each) do
      Income.any_instance.stub(valid?: true, contact: contact)
      IncomeDetail.any_instance.stub(valid?: true)
    end

    subject { Incomes::Form.new_income(valid_params) }

    it "creates and sets the default states" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create.should be_true

      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_draft
      i.should be_active
      i.ref_number.should =~ /I-\d{2}-\d{4}/
      i.date.should be_is_a(Date)

      i.creator_id.should eq(UserSession.id)
      i.balance_inventory.should == 500

      # Number values
      i.exchange_rate.should == 1
      i.total.should == total

      i.gross_total.should == (10 * 10.5 + 20 * 20.0)
      i.balance.should == total
      i.gross_total.should > i.total

      i.discount == i.gross_total - total
      i.should be_discounted

      i.income_details[0].original_price.should == 10.5
      i.income_details[0].balance.should == 10.0
      i.income_details[1].original_price.should == 20.0
      i.income_details[1].balance.should == 20.0
    end

    it "creates and approves" do
      # Create
      subject.create_and_approve.should be_true

      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_approved
      i.should be_active
      i.due_date.should eq(i.date)
      i.approver_id.should eq(UserSession.id)
      i.approver_datetime.should be_is_a(Time)
    end
  end

  context "Update" do
    before(:each) do
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      ConciliateAccount.any_instance.stub(account_to: stub(save: true, :amount= => true, amount: 1))
    end

    let(:subject) do
      inc = Incomes::Form.new_income(valid_params)
      inc.create
      inc
    end

    let(:update_details) {
      subject.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity + 2, price: det.price}
      }
    }

    let(:total_for_update) { subject.total + 10 * 2 + 20 * 2 }
    let(:attributes_for_update) {
      valid_params.merge(total: total_for_update,
                         description: 'A new changed description', income_details_attributes: update_details)
    }

    it "does not allow errors on IncomeDetail" do
      i = subject.income
      is = Incomes::Form.find(i.id)
      is.income.stub(valid?: false)
      is.details[0].errors.add(:quantity, "Error in quantity")

      is.update.should be_false
      is.income.details[0].errors[:quantity].should eq(["Error in quantity"])
    end

    it "udpates balance_inventory" do
      i = subject.income
      i.details[0].balance.should == 10
      i.details[1].balance.should == 20
      i.balance_inventory.should == 500

      incf = Incomes::Form.find(i.id)
      id = incf.details[0].id

      incf.update(income_details_attributes: [
        {id: id, item_id: 1, price: 10, quantity: 12},
        {item_id: 100, price: 10, quantity: 10}
      ]
      ).should be_true

      i = Income.find(incf.income.id)

      i.details.should have(3).items

      i.details.map(&:item_id).sort.should eq([1, 2, 100])

      i.details[0].quantity.should == 12
      i.details[0].balance.should == 12

      i.balance_inventory.should == 620
    end

    it "Update" do
      i = subject.income
      is = Incomes::Form.find(i.id)
      # Update
      is.update(attributes_for_update.merge(contact_id: 10)).should be_true
      # Income
      i = is.income
      i.should be_is_draft
      i.contact_id.should eq(1) # Does not change contact for update
      i.description.should eq('A new changed description')
      i.total.should == total_for_update

      i.income_details.should have(2).items
      i.income_details[0].quantity.should == 12
      i.income_details[1].quantity.should == 22

      is.history.should be_persisted
    end

    it "Direct payment" do
      AccountLedger.any_instance.stub(valid?: true)
      is = Incomes::Form.find(subject.income.id)
      is.stub(account_to: true)

      is.update_and_approve({direct_payment: true, account_to_id: 1}).should be_true

      is.income_id.should eq(is.income.id)
      # Income
      income = is.income
      income.total.should == 490.0
      income.should be_persisted
      income.id.should be_is_a(Integer)
      income.should be_is_paid
      income.balance.should == 0
      income.currency.should eq('BOB')

      ledger  = is.ledger
      ledger.amount.should == income.total
      ledger.should be_persisted
      ledger.account_id.should eq(income.id)
      ledger.currency.should eq('BOB')
      ledger.should be_is_payin
      ledger.exchange_rate.should == 1
      ledger.should be_is_approved
      ledger.status.should eq('approved')
      ledger.approver_id.should be_is_a(Integer)
    end

    it "update_and_approve" do
      i = subject.income
      is = Incomes::Form.find(i.id)

      is.update({}).should be_true
      is.income.should be_is_draft

      is = Incomes::Form.find(i.id)
      is.update_and_approve({})
      is.income.should be_is_approved
    end
  end

  describe "direct_payment" do
    before(:each) do
      AccountLedger.any_instance.stub(valid?: true)
      Income.any_instance.stub(valid?: true)
      IncomeDetail.any_instance.stub(valid?: true)
      Item.stub_chain(:where, values_of: [[1, 10], [2, 20.0]])
      ConciliateAccount.any_instance.stub(account_to: stub(save: true, :amount= => true, amount: 1))
    end

    it "creates and pays" do
      is = Incomes::Form.new_income(valid_params.merge(direct_payment: "1", account_to_id: "2", reference: 'Recibo 123'))
      is.stub(account_to: true)

      is.create_and_approve.should be_true

      is.ledger.should be_is_a(AccountLedger)
      # ledger
      is.ledger.account_id.should be_is_a(Integer)
      is.ledger.should be_persisted
      is.ledger.account_to_id.should eq(2)
      is.ledger.should be_is_payin
      is.ledger.amount.should == 490.0
      is.ledger.reference.should eq('Recibo 123')

      # income
      is.income.total.should == 490.0
      is.income.balance.should == 0.0
      is.income.discount.should == 10.0
      is.income.should be_is_paid
    end

    it "updates and pays" do
      is = Incomes::Form.new_income(valid_params)
      is.create.should be_true
      is.income.should be_persisted
      inc = is.income
      inc.should be_discounted
      inc.discount.should == 10

      is = Incomes::Form.find(inc.id)
      is.income.should eq(inc)

      is.ref_number.should eq(inc.ref_number)
      is.total.should == 490.0

      is.stub(account_to: true)
      is.update_and_approve(direct_payment: "1", account_to_id: "2", total: 500).should be_true

      is.ledger.should be_is_a(AccountLedger)
      # ledger
      is.ledger.account_id.should be_is_a(Integer)
      is.ledger.account_to_id.should eq(2)
      is.ledger.reference.should eq("Cobro ingreso #{inc}")
      is.ledger.date.to_date.should eq(is.date)
      is.ledger.should be_is_payin
      is.ledger.amount.should == is.income.total

      # income
      is.income.should be_is_paid
      is.income.total.should == 500.0
      is.income.balance.should == 0.0
      is.income.should_not be_discounted
      is.income.discount.should == 0

      # UPDATE and check errors
      attrs = is.income.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity - 2, price: det.price}
      }

      is = Incomes::Form.find(is.income.id)
      is.update(total: 440, income_details_attributes: attrs).should be_true
      is.income.error_messages.should eq({"balance" => ["movement.negative_balance"]})
      is.income.should be_has_error
    end
  end

  it "sets errors from expense or ledger" do
    is = Incomes::Form.new_income(direct_payment: true)

    is.create.should be_false

    is.errors.messages[:contact_id].should_not be_blank
    is.errors.messages[:account_to_id].should_not be_blank
    is.errors.messages[:currency].should_not be_blank
  end
end
