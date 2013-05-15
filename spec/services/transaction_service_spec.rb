# encoding: utf-8
require 'spec_helper'

describe TransactionService do
  subject { should respond_to(:transaction) }

  describe "Attributes" do
    subject { TransactionService.new {} }

    it "responds to" do
      [:date, :contact_id, :currency, :exchange_rate,
       :project_id, :due_date, :description,
       :direct_payment, :account_to_id
      ].each do |key|
        subject.should respond_to(key)
        subject.should respond_to(:"#{key}=")
      end
    end
  end

  it "#attibutes" do
    TransactionService::TRANS_ATTRIBUTES.should eq([:date, :contact_id, :total, :exchange_rate, :project_id, :due_date, :description])
  end
end
