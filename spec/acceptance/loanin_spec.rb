# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test loanin" do
  background do
    create_currencies
    create_account_types
    UserSession.current_user = mock_model(User, id: 10)
    OrganisationSession.stub!(currency_id: 1)
  end

  let!(:client) { Factory.create(:client) }
  let!(:bank) { Factory.create(:bank) }
  let!(:account) { bank.account }

  let(:valid_attributes) {
    { 
      ref_number: "123", 
      contact_id: client.id, 
      total: 1000, 
      account_id: account.id,
      date: Date.today
    }  
  }

  scenario "It should create a loan" do
    li = Loanin.new(valid_attributes.merge(action: "no"))
    li.action = "edit"

    li.save.should be_true
    li.ref_number.should == "123"
    li.contact_id.should == client.id
    li.total.should == 1000
    li.balance.should == 0
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
    client.account_cur(1).amount.should == 0

    li.should be_persisted
    li.should be_is_in_edit
    li.account_ledgers.should be_empty
    li.pay_plans.should be_empty
    li.balance.should == 0

    account.reload.amount.should == amt

    li.approve_loan.should be_true
    li.balance.should == li.total
    li.account_ledger.should_not be_blank
    al = li.account_ledger
    al.amount.should == li.balance
    al.should be_persisted
    al.reference.should =~ /Ingreso/
    al.transaction_type.should == "Loanin"
    pp = li.pay_plans.first
    pp.amount.should == li.balance
    pp.should be_persisted

    account.reload.amount.should == amt + li.balance
    client.account_cur(1).amount.should == -li.balance
  end

  scenario "It should create pay_plans and receive payments" do
    li = Loanin.create!(valid_attributes) {|l| l.action = "edit" }

    li.pay_plans.count.should == 0

    li.approve_loan.should be_true

    li.reload
    li.balance.should == li.total
    li.pay_plans.count.should == 1
    pp = li.pay_plans.first

    li.edit_pay_plan(pp.id, amount: 100, repeat: "1")

    li.save_pay_plan.should be_true
    
    li.reload
    
    li.pay_plans.first.amount.should == 100
    li.balance.should == li.total
    tot_pps = li.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    
    tot_pps.should == li.balance
    li.pay_plans.count.should == 10

    #li.new_payment
  end
end
