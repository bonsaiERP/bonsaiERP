describe QuickExpense do
  let(:user) { build :user, id: 21 }

  before(:each) do
    UserSession.current_user = User.new {|u| u.id = 21 }
    UserChange.any_instance.stub(save: true, user: user)
  end

  let!(:contact) { create(:contact) }
  let!(:cash) { create(:cash, amount: 100, currency: 'BOB') }
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
      qe = QuickExpense.new(valid_attributes)
      qe.create.should be_true

      qe.expense.should be_persisted
      qe.account_ledger.should be_persisted
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
      expense.should be_is_paid
      expense.date.should_not be_blank
      expense.payment_date.should eq(expense.date)

      expense.user_changes.should have(2).items
      expense.user_changes.map(&:name).sort.should eq(['approver', 'creator'])
      expense.user_changes.map(&:user_id).should eq([21, 21])
    end

    it "account_ledger attribtes are set for out" do
      account_ledger.contact_id.should eq(contact.id)
      account_ledger.should be_persisted
      account_ledger.should be_is_payout
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
