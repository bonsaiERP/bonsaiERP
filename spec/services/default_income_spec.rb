# encoding: utf-8
describe DefaultIncome do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { 490 }
  let(:details_total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:income) do
    Income.new_income(
      date: Date.today ,currency: 'BOB',
      description: "New income description", state: "draft", total: 490,
      income_details_attributes: details
    )
  end
  let(:valid_params) { {
      date: Date.today, contact_id: 1, total: total,
      currency: 'BOB', bill_number: "I-0001", description: "New income description",
      income_details_attributes: details
    }
  }

  before(:each) do
    UserSession.user = build :user, id: 10
  end

  it "does not allow a class that is not an income" do
    expect { DefaultIncome.new(Expense.new) }.to raise_error
  end

  context "Initialization" do
    subject { DefaultIncome.new(income) }

    it "sets all parameters" do
      income.should be_is_a(Income)
      income.ref_number.should be_blank
      income.income_details.should have(2).items

      income.income_details[0].item_id.should eq(details[0][:item_id])
      income.income_details[0].description.should eq(details[0][:description])
      income.income_details[1].item_id.should eq(details[1][:item_id])
    end
  end

  context "Create a income with default data" do
    before(:each) do
      Income.any_instance.stub(save: true)
      IncomeDetail.any_instance.stub(save: true)
    end

    subject {
      DefaultIncome.new(income) 
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
      i.ref_number.should eq('I-0001')
      i.date.should be_is_a(Date)
      #i.payment_date.should eq(i.date)

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
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])
      
      Item.should_receive(:where).with(id: item_ids).and_return(s)

      # Create
      subject.create_and_approve.should be_true

      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_approved
      i.should be_active
      i.ref_number.should eq('I-0001')
      i.date.should be_is_a(Date)
      i.payment_date.should eq(i.date)

      i.creator_id.should eq(UserSession.id)
      i.approver_id.should eq(UserSession.id)
      i.approver_datetime.should be_is_a(Time)

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
    it "checks there is no error" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.0], [2, 20.0]])
      Item.should_receive(:where).with(id: item_ids).and_return(s)
      
      subject.income.total = details_total

      # Create
      subject.create.should be_true

      # Income
      i = subject.income

      # Number values
      i.exchange_rate.should == 1
      i.total.should == details_total

      i.gross_total.should == details_total
      i.balance.should == details_total
      i.gross_total.should == (10 * 10 + 20 * 20)

      i.discount == 0
      i.should_not be_discounted

      i.income_details[0].original_price.should == 10.0
      i.income_details[0].balance.should == 10.0
      i.income_details[1].original_price.should == 20.0
      i.income_details[1].balance.should == 20.0
      #
    end
  end
end
