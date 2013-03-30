# encoding: utf-8
describe ExpenseService do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { 490 }
  let(:details_total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:valid_params) { {
      date: Date.today, contact_id: 1, total: total,
      currency: 'BOB', bill_number: "E-0001", description: "New expense description",
      expense_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

  context "Initialization" do
    subject { ExpenseService.new(valid_params) }

    it "expense_details" do
      subject.expense.should be_is_a(Expense)
      subject.expense.expense_details.should have(2).items

      subject.expense.expense_details[0].item_id.should eq(details[0][:item_id])
      subject.expense.expense_details[0].description.should eq(details[0][:description])
      subject.expense.expense_details[0].price.should eq(details[0][:price])
      subject.expense.expense_details[0].quantity.should eq(details[0][:quantity])
      subject.expense.expense_details[1].item_id.should eq(details[1][:item_id])
    end

    it "sets_defaults if nil" do
      es = ExpenseService.new
      es.expense.ref_number.should =~ /E-\d{2}-000\d/
      es.expense.currency.should eq('BOB')
      es.expense.date.should eq(Date.today)

      es.expense_details.should have(1).item
    end
  end

  it "#valid?" do
    es = ExpenseService.new(account_to_id: 2, direct_payment: "1")

    es.should_not be_valid
    AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

    es = ExpenseService.new(account_to_id: 2, direct_payment: "1")

    es.should be_valid
  end

  context "Create a expense with default data" do
    before(:each) do
      Expense.any_instance.stub(save: true)
      ExpenseDetail.any_instance.stub(save: true)
    end

    subject {
      ExpenseService.new(valid_params)
    }

    it "creates and sets the default states" do
      s = stub
      s.should_receive(:values_of).with(:id, :buy_price).and_return([[1, 10.5], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create.should be_true

      # Expense
      i = subject.expense
      i.should be_is_a(Expense)
      i.should be_is_draft
      i.should be_active
      i.ref_number.should =~ /E-\d{2}-\d{4}/
      i.date.should be_is_a(Date)

      i.creator_id.should eq(UserSession.id)

      # Number values
      i.exchange_rate.should == 1
      i.total.should == total

      i.gross_total.should == (10 * 10.5 + 20 * 20.0)
      i.balance.should == total
      i.gross_total.should > i.total

      i.discount == i.gross_total - total
      i.should be_discounted

      i.expense_details[0].original_price.should == 10.5
      i.expense_details[0].balance.should == 10.0
      i.expense_details[1].original_price.should == 20.0
      i.expense_details[1].balance.should == 20.0
    end

    it "creates and approves" do
      subject.should_receive(:set_expense_data).and_return(true)
      # Create
      subject.create_and_approve.should be_true

      # Expense
      i = subject.expense
      i.should be_is_a(Expense)
      i.should be_is_approved
      i.should be_active
      i.due_date.should eq(i.date)
      i.approver_id.should eq(UserSession.id)
      i.approver_datetime.should be_is_a(Time)
    end

  end

  context "Update" do
    before(:each) do
      Expense.any_instance.stub(save: true)
      ExpenseDetail.any_instance.stub(save: true)
    end

    subject {
      ExpenseService.new(valid_params)
    }

    it "Updates with errors on expense" do
      TransactionHistory.any_instance.should_receive(:create_history).and_return(true)

      i = subject.expense
      i.total = details_total
      i.balance = 0
      i.stub(total_was: i.total)

      i.should be_is_draft
      i.total.should > 200

      attributes = valid_params.merge(total: 200)
      # Create
      subject.update(attributes).should be_true

      # Expense
      i = subject.expense

      i.should be_is_paid
      i.should be_has_error
      i.error_messages[:balance].should_not be_blank
    end

    it "update_and_approve" do
      TransactionHistory.any_instance.stub(create_history: true)

      subject.update({}).should be_true
      subject.expense.should be_is_draft

      subject.update_and_approve({})
      subject.expense.should be_is_approved
    end

  end

  describe "create and pay" do
    let(:cash) { build :cash, currency: 'BOB', id: 2 }
    let(:contact) { build :contact, id: 1 }

    before(:each) do
      AccountLedger.any_instance.stub(save_ledger: true)
      Expense.any_instance.stub(contact: contact, id: 100, save: true)
      ExpenseDetail.any_instance.stub(save: true)
    end


    it "creates and pays" do
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

      s = stub
      s.should_receive(:values_of).with(:id, :buy_price).and_return([[1, 10], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      es = ExpenseService.new(valid_params.merge(direct_payment: "1", account_to_id: "2"))
      es.create_and_approve.should be_true

      es.ledger.should be_is_a(AccountLedger)
      # ledger
      es.ledger.account_id.should eq(100)
      es.ledger.account_to_id.should eq(2)
      es.ledger.should be_is_payin
      es.ledger.amount.should == -490.0

      # expense
      es.expense.total.should == 490.0
      es.expense.balance.should == 0.0
      es.expense.discount.should == 10.0
      es.expense.should be_is_paid
    end

    it "sets errors from expense or ledger" do
      es = ExpenseService.new

      es.expense.stub(save: false)
      es.expense.errors[:contact_id] << "Wrong"

      es.create_and_approve.should be_false
      es.errors[:contact_id].should eq(["Wrong"])

      # Errors on both expense and ledger
      es = ExpenseService.new(direct_payment: true)
      es.stub(account_to: build(:cash, id: 3) )

      es.expense.stub(save: false)
      es.expense.errors[:contact_id] << "Wrong"
      es.stub(ledger: build(:account_ledger))
      es.ledger.errors[:reference] << "Blank reference"

      es.create_and_approve.should be_false

      es.errors[:contact_id].should eq(["Wrong"])
      es.errors[:base].should eq(["Blank reference"])
    end
  end
end

