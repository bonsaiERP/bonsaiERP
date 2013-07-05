# encoding: utf-8
describe Expenses::Form do
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
      currency: 'BOB', description: "New expense description",
      expense_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

  context "Initialization" do
    subject { Expenses::Form.new_expense(valid_params) }

    it "expense_details" do
      subject.expense.should be_is_a(Expense)
      subject.date.should be_is_a(Date)
      subject.currency.should eq('BOB')
      subject.expense.expense_details.should have(2).items

      subject.expense.expense_details[0].item_id.should eq(details[0][:item_id])
      subject.expense.expense_details[0].description.should eq(details[0][:description])
      subject.expense.expense_details[0].price.should eq(details[0][:price])
      subject.expense.expense_details[0].quantity.should eq(details[0][:quantity])
      subject.expense.expense_details[1].item_id.should eq(details[1][:item_id])
      subject.should respond_to(:expense_details)
      subject.should respond_to(:expense_details_attributes)
      subject.should respond_to(:expense_details_attributes=)
    end

    it "sets_defaults if nil" do
      Date.stub(today: Date.today)

      is = Expenses::Form.new_expense
      is.expense.ref_number.should =~ /E-\d{2}-000\d/
      is.expense.currency.should eq('BOB')
      is.expense.date.should eq(Date.today)
    end
  end

  context "Validation" do
    it "#valid?" do
      es = Expenses::Form.new_expense(account_to_id: 2, direct_payment: "1")

      es.should_not be_valid
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

      es = Expenses::Form.new_expense(account_to_id: 2, direct_payment: "1", total: 150)
      es.details.should have(2).items
      es.details.map(&:quantity).should eq([1,1])
    end

    it "unique items" do
      es = Expenses::Form.new_expense(expense_details_attributes: [
        {item_id: 1, quantity: 10, price: 1}, {item_id: 2, quantity: 10, price: 3},
        {item_id: 1, quantity: 3, price: 5}
      ])
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])
      ExpenseDetail.any_instance.stub(item: true)

      es.should_not be_valid
      es.errors[:base].should eq([I18n.t("errors.messages.item.repeated_items")])
      es.expense.expense_details[0].errors.should be_blank
      es.expense.expense_details[1].errors.should be_blank
      es.expense.expense_details[2].errors[:item_id].should eq([I18n.t("errors.messages.item.repeated")])
    end
  end

  context "Create a expense with default data" do
    before(:each) do
      Expense.any_instance.stub(valid?: true, contact: contact)
      ExpenseDetail.any_instance.stub(valid?: true)
    end

    subject { Expenses::Form.new_expense(valid_params) }

    it "creates and sets the default states" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create.should be_true

      # Expense
      e = subject.expense
      e.should be_is_a(Expense)
      e.should be_is_draft
      e.should be_active
      e.ref_number.should =~ /E-\d{2}-\d{4}/
      e.date.should be_is_a(Date)

      e.creator_id.should eq(UserSession.id)

      # Number values
      e.exchange_rate.should == 1
      e.total.should == total

      e.gross_total.should == (10 * 10.5 + 20 * 20.0)
      e.balance.should == total
      e.gross_total.should > e.total

      e.discount == e.gross_total - total
      e.should be_discounted

      e.expense_details[0].original_price.should == 10.5
      e.expense_details[0].balance.should == 10.0
      e.expense_details[1].original_price.should == 20.0
      e.expense_details[1].balance.should == 20.0
    end

    it "creates and approves" do
      # Create
      subject.create_and_approve.should be_true

      # Expense
      e = subject.expense
      e.should be_is_a(Expense)
      e.should be_is_approved
      e.should be_active
      e.due_date.should eq(e.date)
      e.approver_id.should eq(UserSession.id)
      e.approver_datetime.should be_is_a(Time)
    end
  end

  context "Update" do
    before(:each) do
      Expense.any_instance.stub(valid?: true)
      ExpenseDetail.any_instance.stub(valid?: true)
      ConciliateAccount.any_instance.stub(account_to: stub(save: true, :amount= => true, amount: 1))
    end

    let(:subject) do
      exp = Expenses::Form.new_expense(valid_params)
      exp.create
      exp
    end

    let(:update_details) {
      subject.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity + 2, price: det.price}
      }
    }

    let(:total_for_update) { subject.total + 10 * 2 + 20 * 2 }
    let(:attributes_for_update) {
      valid_params.merge(total: total_for_update,
                         description: 'A new changed description', expense_details_attributes: update_details)
    }

    it "does not allow errors on ExpenseDetail" do
      e = subject.expense
      es = Expenses::Form.find(e.id)
      es.expense.stub(valid?: false)
      es.details[0].errors.add(:quantity, "Error in quantity")

      es.update.should be_false
      es.expense.details[0].errors[:quantity].should eq(["Error in quantity"])
    end

    it "udpates balance_inventory" do
      e = subject.expense
      e.details.should have(2).items
      e.details[0].balance.should == 10
      e.details[1].balance.should == 20
      e.balance_inventory.should == 500

      expf = Expenses::Form.find(e.id)
      id = expf.details[0].id

      expf.update(expense_details_attributes: [
        {id: id, item_id: 1, price: 10, quantity: 12},
        {item_id: 100, price: 10, quantity: 10}
      ]
      ).should be_true

      e = Expense.find(expf.expense.id)

      e.details.should have(3).items

      e.details.map(&:item_id).sort.should eq([1, 2, 100])

      e.details[0].quantity.should == 12
      e.details[0].balance.should == 12

      e.balance_inventory.should == 620
    end

    it "Update" do
      e = subject.expense
      es = Expenses::Form.find(e.id)
      # Update
      es.update(attributes_for_update.merge(contact_id: 10)).should be_true
      # Expense
      e = es.expense
      e.should be_is_draft
      e.contact_id.should eq(1) # Does not change contact for update
      e.description.should eq('A new changed description')
      e.total.should == total_for_update

      e.expense_details.should have(2).items
      e.expense_details[0].quantity.should == 12
      e.expense_details[1].quantity.should == 22

      es.history.should be_persisted
    end

    it "Direct payment" do
      AccountLedger.any_instance.stub(valid?: true)
      es = Expenses::Form.find(subject.expense.id)
      es.stub(account_to: true)

      es.update_and_approve({direct_payment: true, account_to_id: 1}).should be_true

      es.expense_id.should eq(es.expense.id)
      # Expense
      expense = es.expense
      expense.should be_persisted
      expense.id.should be_is_a(Integer)
      expense.should be_is_paid
      expense.balance.should == 0
      expense.currency.should eq('BOB')

      ledger  = es.ledger
      ledger.amount.should == -490.0
      ledger.should be_persisted
      ledger.account_id.should eq(expense.id)
      ledger.currency.should eq('BOB')
      ledger.should be_is_payout
      ledger.exchange_rate.should == 1
      ledger.should be_is_approved
      ledger.status.should eq('approved')
      ledger.approver_id.should be_is_a(Integer)
    end

    it "update_and_approve" do
      i = subject.expense
      is = Expenses::Form.find(i.id)

      is.update({}).should be_true
      is.expense.should be_is_draft

      is = Expenses::Form.find(i.id)
      is.update_and_approve({})
      is.expense.should be_is_approved
    end
  end

  describe "direct_payment" do
    before(:each) do
      AccountLedger.any_instance.stub(valid?: true)
      Expense.any_instance.stub(valid?: true)
      ExpenseDetail.any_instance.stub(valid?: true)
      Item.stub_chain(:where, values_of: [[1, 10], [2, 20.0]])
      ConciliateAccount.any_instance.stub(account_to: stub(save: true, :amount= => true, amount: 1))
    end

    it "creates and pays" do
      is = Expenses::Form.new_expense(valid_params.merge(direct_payment: "1", account_to_id: "2", reference: 'Recibo 123'))
      is.stub(account_to: true)

      is.create_and_approve.should be_true

      is.ledger.should be_is_a(AccountLedger)
      # ledger
      is.ledger.account_id.should be_is_a(Integer)
      is.ledger.should be_persisted
      is.ledger.account_to_id.should eq(2)
      is.ledger.should be_is_payout
      is.ledger.amount.should == -490.0
      is.ledger.reference.should eq('Recibo 123')

      # expense
      is.expense.total.should == 490.0
      is.expense.balance.should == 0.0
      is.expense.discount.should == 10.0
      is.expense.should be_is_paid
    end

    it "updates and pays" do
      es = Expenses::Form.new_expense(valid_params)
      es.create.should be_true
      es.expense.should be_persisted
      exp = es.expense
      exp.should be_discounted
      exp.discount.should == 10

      es = Expenses::Form.find(exp.id)
      es.expense.should eq(exp)

      es.ref_number.should eq(exp.ref_number)
      es.total.should == 490.0

      es.stub(account_to: true)
      es.update_and_approve(direct_payment: "1", account_to_id: "2", total: 500).should be_true

      es.ledger.should be_is_a(AccountLedger)
      # ledger
      es.ledger.amount.should == -500.0
      es.ledger.account_id.should be_is_a(Integer)
      es.ledger.account_to_id.should eq(2)
      es.ledger.reference.should eq("Pago egreso #{exp}")
      es.ledger.date.to_date.should eq(es.date)
      es.ledger.should be_is_payout
      es.ledger.amount.should == -es.expense.total

      # expense
      es.expense.should be_is_paid
      es.expense.total.should == 500.0
      es.expense.balance.should == 0.0
      es.expense.should_not be_discounted
      es.expense.discount.should == 0

      # UPDATE and check errors
      attrs = es.expense.details.map {|det|
        {id: det.id, item_id: det.item_id, quantity: det.quantity - 2, price: det.price}
      }

      es = Expenses::Form.find(es.expense.id)
      es.update(total: 440, expense_details_attributes: attrs).should be_true
      es.expense.error_messages.should eq({"balance" => ["movement.negative_balance"]})
      es.expense.should be_has_error
    end

  end

  it "sets errors from expense or ledger" do
    es = Expenses::Form.new_expense(direct_payment: true)

    es.create.should be_false

    es.errors.messages[:contact_id].should_not be_blank
    es.errors.messages[:account_to_id].should_not be_blank
    es.errors.messages[:currency].should_not be_blank
  end

  it "generates erros and does not raise exception" do
    es = Expenses::Form.new_expense(valid_params.merge(total: ""))
    expect(es).to_not be_valid

    es.errors[:total].should_not be_blank

    es = Expenses::Form.new_expense(valid_params.merge(total: "NaN"))
    expect(es).to_not be_valid
    es.errors[:total].should_not be_blank
  end
end

