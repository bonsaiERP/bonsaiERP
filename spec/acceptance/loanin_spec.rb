# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test loanin" do
  background do
    create_currencies
    create_account_types
    UserSession.current_user = mock_model(User, id: 10)
  end

  let!(:client) { Factory.create(:client) }
  let!(:bank) { Factory.create(:bank) }
  let!(:account) { bank.account }

  let(:valid_attributes) {
    { 
      ref_number: "123", 
      contact_id: client.id, 
      total: 1000, 
      account_id: account.id
    }  
  }

  scenario "It should create a loan" do
    li = Loanin.new(valid_attributes.merge(action: "no"))
    li.action = "edit"

    li.save.should be_true
    li.ref_number.should == "123"
    li.contact_id.should == client.id
    li.total.should == 1000
    li.balance.should == 1000
    li.creator_id.should == 10
    li.modified_by.should == 10
    li.currency_id.should == account.currency_id
    li.should be_draft
    li.should be_is_in_edit
    li.should be_persisted
  end

  scenario "It should save and create firs pay_plan after approve" do
    li = Loanin.create!(valid_attributes) {|l| l.action = "edit" }
    amt = account.amount

    li.should be_persisted
    li.should be_is_in_edit
    li.account_ledgers.should be_empty
    li.pay_plans.should be_empty

    account.reload.amount.should == amt

    li.approve_loan.should be_true
    li.account_ledgers.should_not be_empty
    al = li.account_ledgers.first
    al.amount.should == li.balance
    al.should be_persisted
    al.reference.should =~ /Ingreso/
    pp = li.pay_plans.first
    pp.amount.should == li.balance
    p.should be_persisted

    account.reload.amount.should == amt + li.balance
  end
end
