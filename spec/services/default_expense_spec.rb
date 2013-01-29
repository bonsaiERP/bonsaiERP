# encoding: utf-8
describe DefaultExpense do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { 490 }
  let(:details_total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:expense) do
    Expense.new_expense(
      date: Date.today ,currency: 'BOB',
      description: "New expense description", state: "draft", total: 490,
      expense_details_attributes: details
    )
  end
  let(:valid_params) { {
      ref_number: "I0001", date: Date.today, contact_id: 1, total: total,
      currency: 'BOB', bill_number: "I-0001", description: "New expense description",
      expense_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
  end

  it "does not allow a class that is not an expense" do
    expect { DefaultExpense.new(Income.new) }.to raise_error
  end

  context "Initialization" do
    subject { DefaultExpense.new(expense) }

    it "sets all parameters" do
      expense.should be_is_a(Expense)
      expense.ref_number.should be_blank
      expense.expense_details.should have(2).items

      expense.expense_details[0].item_id.should eq(details[0][:item_id])
      expense.expense_details[0].description.should eq(details[0][:description])
      expense.expense_details[1].item_id.should eq(details[1][:item_id])
    end
  end

  context "Create a expense with default data" do
    before(:each) do
      Expense.any_instance.stub(save: true)
      ExpenseDetail.any_instance.stub(save: true)
    end

    subject {
      DefaultExpense.new(expense) 
    }

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

      e.creator_id.should eq(UserSession.id)
      e.due_date.should be_blank

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

    it "creates and sets the approve" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])
      
      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create_and_approve.should be_true

      # Expense
      e = subject.expense
      e.should be_is_a(Expense)
      e.should be_is_approved
      e.should be_active
      e.approver_id.should eq(UserSession.id)
      e.approver_datetime.should be_is_a(Time)
      e.due_date.should be_is_a(Date)
    end

    it "checks there is no error" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.0], [2, 20.0]])
      Item.should_receive(:where).with(id: item_ids).and_return(s)
      
      subject.expense.total = details_total

      # Create
      subject.create.should be_true

      # Expense
      i = subject.expense

      # Number values
      i.exchange_rate.should == 1
      i.total.should == details_total

      i.gross_total.should == details_total
      i.balance.should == details_total
      i.gross_total.should == (10 * 10 + 20 * 20)

      i.discount == 0
      i.should_not be_discounted

      i.expense_details[0].original_price.should == 10.0
      i.expense_details[0].balance.should == 10.0
      i.expense_details[1].original_price.should == 20.0
      i.expense_details[1].balance.should == 20.0
      #
    end
  end
end

