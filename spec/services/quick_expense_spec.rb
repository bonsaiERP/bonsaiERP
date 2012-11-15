describe QuickExpense do
  before(:each) do
    UserSession.current_user = User.new {|u| u.id = 21 }
  end

  let!(:currency) { create(:currency) }
  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 100, currency_id: currency.id) }
  let(:account) { cash.account }
  let(:initial_amount) { account.amount }

  let(:valid_attributes) {
    {
      date: Date.today, ref_number: 'E-0001', fact: true,
      bill_number: '63743', amount: '200.5',
      contact_id: contact.id, account_id: account.id
    }
  }

  it "Initializes with a correct number" do
    qe = QuickExpense.new
    qe.ref_number.should eq("E-0001")
  end

  context "Create expense" do

    it "creates a valid expense" do
      contact.should_not be_supplier
      qi = QuickExpense.new(valid_attributes)
      qi.create.should be_true

      qi.expense.should be_persisted
      qi.account_ledger.should be_persisted
      contact.reload
      contact.should be_supplier
    end

    subject do
      qe = QuickExpense.new(valid_attributes)
      qe.create
      qe
    end


    let(:account_ledger) { subject.account_ledger }
    let(:expense) { subject.expense }
    let(:amount) { subject.amount }

    it "checks the expense" do
      expense.balance.should eq(0)
      expense.total.should eq(amount)
      expense.gross_total.should eq(amount)
      expense.original_total.should eq(amount)
      expense
    end

    it "account_ledger attribtes are set for out" do
      account_ledger.contact_id.should eq(contact.id)
      account_ledger.should be_persisted
      account_ledger.should be_is_pout
      account_ledger.date.to_date.should eq(valid_attributes[:date])
      account_ledger.reference == "Pago egreso #{expense.ref_number}"

      account_ledger.amount.should == -amount
      account_ledger.transaction_id.should eq(expense.id)
      account_ledger.should be_conciliation

      account_ledger.account_amount.should eq(initial_amount - expense.total)
      account_ledger.creator_id.should eq(21)
      account_ledger.approver_id.should eq(21)
      account_ledger.contact_id.should eq(contact.id)
    end
  end
end
