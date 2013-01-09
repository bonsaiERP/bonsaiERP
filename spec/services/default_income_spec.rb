# encoding: utf-8
describe DefaultIncome do
  let(:details) {
    [{item_id: 1, price: 10.0, quantity: 10, description: "First item"},
     {item_id: 2, price: 20.0, quantity: 20, description: "Second item"}
    ]
  }
  let(:item_ids) { details.map {|v| v[:item_id] } }

  let(:total) { details.inject(0) {|s, v| s+= v[:quantity] * v[:price] } }

  let(:income) { build :income, transaction_details_attributes: details }
  let(:valid_params) { {
      ref_number: "I0001", date: Date.today, contact_id: 1, total: total,
      currency: 'BOB', bill_number: "I-0001", description: "New income description",
      transaction_details_attributes: details
    }
  }

  it "does not allow a class that is not an income" do
    expect { DefaultIncome.new(Expense.new) }.to raise_error
  end

  context "Initialization" do
    subject { DefaultIncome.new(income) }

    it "sets all parameters" do
      income.should be_is_a(Income)
      income.ref_number.should eq("I-0001")
      income.transaction_details.should have(2).items

      income.transaction_details[0].item_id.should eq(details[0][:item_id])
      income.transaction_details[0].description.should eq(details[0][:description])
      income.transaction_details[1].item_id.should eq(details[1][:item_id])
    end
  end

  context "Create a income with default data" do
    before(:each) do
      Transaction.any_instance.stub(save: true)
      TransactionDetail.any_instance.stub(save: true)
    end

    subject { DefaultIncome.new(Income.new(valid_params)) }

    it "saves data and sets the default states" do
      s = stub
      s.should_receive(:values_of).with(:id, :price).and_return([[1, 10.5], [2, 20.0]])

      Item.should_receive(:where).with(id: item_ids).and_return(s)
      gross_total = 10 * 10.5 + 20 * 20

      subject.create.should be_true
      # Income
      i = subject.income
      i.should be_is_a(Income)
      i.should be_is_draft
      i.should be_active

      # Number values
      i.exchange_rate.should == 1
      i.gross_total.should == gross_total
      i.total.should == total
      i.balance.should == total
      i.gross_total.should > i.total

      i.transaction_details[0].original_price.should == 10.5
      i.transaction_details[0].balance.should == 10.0
      i.transaction_details[1].original_price.should == 20.0
      i.transaction_details[1].balance.should == 20.0
    end
  end
end
