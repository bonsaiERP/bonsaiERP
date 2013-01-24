# encoding: utf-8
describe QuickExpense do
  let(:user) { build :user, id: 21 }

  before(:each) do
    UserSession.user = User.new {|u| u.id = 21 }
  end

  let(:contact) { build :contact, id: 1 }
  let(:account_to) { build :cash, amount: 100, currency: 'BOB', id: 1 }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today,
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_to_id: account_to.id
    }
  }

  it "should present errors if the contact is wrong" do
    qe = QuickExpense.new(valid_attributes.merge(contact_id: 1000, account_to_id: 1200))
    qe.create.should be_false

    qe.errors_on(:contact).should_not be_blank
    qe.errors_on(:account_to).should_not be_blank
  end

  context "Create expense and check values" do
    before(:each) do
      Expense.any_instance.stub(save: true, id: 11)

      Account.stub(find_by_id: account_to)
      Contact.stub(find_by_id: contact)
      # save_ledger conciliates if conciliation = true
      AccountLedger.any_instance.stub(save_ledger: true)
    end

    it "creates a valid expense" do
      qe = QuickExpense.new(valid_attributes)
      qe.create.should be_true

      # expense
      expense = qe.expense
      expense.should be_is_a(Expense)
      expense.ref_number.should =~ /E-\d{2}-\d{4}/
      expense.currency.should eq('BOB')
      expense.total.should == 200.5
      expense.balance.should == 0.0
      expense.gross_total.should == 200.5
      expense.total.should == 200.5
      expense.original_total.should == 200.5
      expense.date.should eq(valid_attributes.fetch(:date) )
      expense.payment_date.should eq(expense.date)

      expense.creator_id.should eq(21)
      expense.approver_id.should eq(21)
      expense.approver_datetime.should be_is_a(Time)

      # account_ledger
      ledger = qe.account_ledger
      ledger.account_id.should eq(11)
      ledger.account_to_id.should eq(account_to.id)
      ledger.currency.should eq("BOB")

      ledger.amount.should == -200.5
      ledger.exchange_rate.should == 1
      ledger.should_not be_inverse

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)

      ledger.reference.should eq("Egreso rápido #{expense.ref_number}")
      ledger.should be_is_payout
      
      ledger.should be_conciliation
      ledger.date.should be_a(Time)

      ledger.creator_id.should eq(21)
      ledger.approver_id.should eq(21)
    end

    it "No conciliation required when account_to is Cash" do
      qe = QuickExpense.new(valid_attributes.merge(verification: true))
      qe.create.should be_true

      qe.send(:account_to).should be_is_a(Cash)
      #AccountLedger conciliated
      qe.account_ledger.should be_conciliation
    end

    it "Can accept different values for conciliation when Bank account" do
      Account.stub(find_by_id: build(:bank, id: 3))

      qe = QuickExpense.new(valid_attributes.merge(account_to_id: 3, verification: true))
      qe.create.should be_true

      ledger = qe.account_ledger

      ledger.should_not be_conciliation

      # Other case
      qe = QuickExpense.new(valid_attributes.merge(account_to_id: 3, verification: false))
      qe.create.should be_true

      ledger = qe.account_ledger

      ledger.should be_conciliation
    end

    it "Assigns the currency of the account" do
      Account.stub(find_by_id: build(:bank, id: 3, currency: 'USD'))
      
      qe = QuickExpense.new(valid_attributes.merge(account_to_id: 3) )

      qe.create.should be_true

      qe.expense.currency.should eq('USD')
    end

  end

end
