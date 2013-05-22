require 'spec_helper'

describe Expenses::Query do
  subject { Expenses::Query.new }

  it "Initializes with " do
    subject.instance_variable_get(:@rel).to_s.should eq('Expense')
  end

  it "returns the contacts from the expense for exchanges" do
    cid = 10
    #subject.exchange(cid).to_sql.should == "SELECT \"accounts\".* FROM \"accounts\" INNER JOIN \"transactions\" ON \"transactions\".\"account_id\" = \"accounts\".\"id\" WHERE \"accounts\".\"type\" IN ('Expense') AND \"accounts\".\"contact_id\" = #{cid} AND ((\"transactions\".\"balance\" > 0 AND \"accounts\".\"active\" = 't' AND \"accounts\".\"state\" = 'approved'))"
  end
end
