# encoding: utf-8
describe IncomeService do
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
      currency: 'BOB', bill_number: "I-0001", description: "New income description",
      income_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
    OrganisationSession.organisation = build :organisation, currency: 'BOB'
  end

  context "Initialization" do
    subject { IncomeService.new(valid_params) }

    it "income_details" do
      subject.income.should be_is_a(Income)
      subject.income.income_details.should have(2).items

      subject.income.income_details[0].item_id.should eq(details[0][:item_id])
      subject.income.income_details[0].description.should eq(details[0][:description])
      subject.income.income_details[0].price.should eq(details[0][:price])
      subject.income.income_details[0].quantity.should eq(details[0][:quantity])
      subject.income.income_details[1].item_id.should eq(details[1][:item_id])
    end

    it "sets_defaults if nil" do
      is = IncomeService.new
      is.income.ref_number.should =~ /I-\d{2}-000\d/
      is.income.currency.should eq('BOB')
      is.income.date.should eq(Date.today)
    end
  end

  it "#valid?" do
    is = IncomeService.new(account_to_id: 2, direct: "1")

    is.should_not be_valid
    AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

    is = IncomeService.new(account_to_id: 2, direct: "1")

    is.should be_valid
  end

  context "Create a income with default data" do
    before(:each) do
      Income.any_instance.stub(save: true)
      IncomeDetail.any_instance.stub(save: true)
    end

    subject {
      IncomeService.new(valid_params)
    }

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
      subject.should_receive(:set_income_data).and_return(true)
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
      Income.any_instance.stub(save: true)
      IncomeDetail.any_instance.stub(save: true)
    end

    subject {
      IncomeService.new(valid_params)
    }

    it "Updates with errors on income" do
      TransactionHistory.any_instance.should_receive(:create_history).and_return(true)

      i = subject.income
      i.total = details_total
      i.balance = 0
      i.stub(total_was: i.total)

      i.should be_is_draft
      i.total.should > 200

      attributes = valid_params.merge(total: 200)
      # Create
      subject.update(attributes).should be_true

      # Income
      i = subject.income

      i.should be_is_paid
      i.should be_has_error
      i.error_messages[:balance].should_not be_blank
    end

    it "update_and_approve" do
      TransactionHistory.any_instance.stub(create_history: true)

      subject.update({}).should be_true
      subject.income.should be_is_draft

      subject.update_and_approve({})
      subject.income.should be_is_approved
    end

  end

  describe "create and pay" do
    let(:cash) { build :cash, currency: 'BOB', id: 2 }
    let(:contact) { build :contact, id: 1 }

    before(:each) do
      AccountLedger.any_instance.stub(save_ledger: true)
      Income.any_instance.stub(contact: contact, id: 100, save: true)
      IncomeDetail.any_instance.stub(save: true)
    end


    it "creates and pays" do
      AccountQuery.any_instance.stub_chain(:bank_cash, where: [( build :cash, id: 2 )])

      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)

      is = IncomeService.new(valid_params.merge(direct: "1", account_to_id: "2"))
      is.create.should be_true

      is.ledger.should be_is_a(AccountLedger)
      # ledger
      is.ledger.account_id.should eq(100)
      is.ledger.account_to_id.should eq(2)
      is.ledger.should be_is_payin
      is.ledger.amount.should == 490.0

      # income
      is.income.total.should == 490.0
      is.income.balance.should == 0.0
      is.income.discount.should == 10.0
      is.income.should be_is_paid
    end
  end
end
