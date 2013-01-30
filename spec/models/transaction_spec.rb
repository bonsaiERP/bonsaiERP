require 'spec_helper'

describe Transaction do
  it { should belong_to(:income) }
  it { should belong_to(:expense) }

  it { should belong_to(:creator) }
  it { should belong_to(:approver) }
  it { should belong_to(:nuller) }

  it "returns its columns for transaction" do
    cols = Transaction.column_names
    %w(id account_id created_at updated_at).each {|k| cols.delete(k) }

    Transaction.transaction_columns.should eq(cols) 
  end
end
