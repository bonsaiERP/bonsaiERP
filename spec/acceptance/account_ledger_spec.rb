# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test account ledger", "for in outs and transferences" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new {|u| u.id = 1}

    create_currencies
    create_account_types
    b = create_bank(:currency_id => 1, :name => "Bank chiquito")
    @bank_ac_ic = b.account.id
    c = create_client(:matchcode => "Lucas Estrella")
    @cli_ac_id = c.account.id

    @params = {
      :date => Date.today, :operation => "in", :reference => "For more", :amount => 100,
      :account_id => @bank_ac_ic, :to_id => @cli_ac_id
    }
  end

  scenario "It should correctly assing the correct methods for money" do

    al = AccountLedger.new_money(:operation => "in", :account_id => 1)

    al.to_id.should == nil
    al.in?.should == true
    al.account.currency_symbol.should == "Bs."
    al.active.should == true

    al = AccountLedger.new_money(:operation => "in", :account_id => 1, :to_id => @cli_ac_id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true

    al.active.should == true

    al.description.should == "Ingreso por #{al.to}"
    al.creator_id.should == 1

    al.currency_id.should == 1
    al.amount.should == 100
    al.conciliation.should == false

    det1 = al.account_ledger_details[0]
    det2 = al.account_ledger_details[1]

    det1.account_id.should == @bank_ac_ic
    det1.amount.should == 100
    det1.currency_id.should == 1
    det1.exchange_rate.should == 1
    det1.account.amount.should == 0

    det2.account_id.should == @cli_ac_id
    det2.amount.should == -100
    det2.currency_id.should == 1
    det2.exchange_rate.should == 1
    det2.account.amount.should == 0
    det2.account.cur(1).amount.should == 0

    UserSession.current_user = User.new{|u| u.id= 2}

    al.conciliate_account

    al.conciliation.should == true
    al.approver_id.should == 2
    al.approver_datetime.kind_of?(Time).should == true

    det1.account_id.should == @bank_ac_ic
    det1.amount.should == 100
    det1.currency_id.should == 1
    det1.exchange_rate.should == 1
    det1.account.amount.should == 100
    det1.account.cur(1).amount.should == 100

    det2.account_id.should == @cli_ac_id
    det2.amount.should == -100
    det2.currency_id.should == 1
    det2.exchange_rate.should == 1
    det2.account.amount.should == -100
    det2.account.cur(1).amount.should == -100
  end

  scenario "It should create amount between two different currencies" do
    b = create_bank(:currency_id => 2)
    b.account.currency_id.should == 2

    al = AccountLedger.new_money(:operation => "in", :account_id => b.account.id, :to_id => @cli_ac_id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true



    det1 = al.account_ledger_details[0]
    det2 = al.account_ledger_details[1]

    det1.account.cur(2).amount.should == 0
    det2.account.amount.should == 0

    al.conciliate_account

    det2.account.cur(1).amount.should == 0
    det2.account.cur(2).amount.should == -100
  end

  scenario "It should create an out" do
    al = AccountLedger.new_money(:operation => "out", :account_id => @bank_ac_ic,              
           :to_id => @cli_ac_id, :amount => 100, :reference => "Check 1120012" )
    

    al.save.should == true
    al.organisation_id.should == 1
    al.description.should =~ /Egreso para/
    al.amount.should == -100
    al.operation.should == "out"

    det1 = al.account_ledger_details[0]
    det2 = al.account_ledger_details[1]

    det1.amount.should == -100
    det1.state.should == "uncon"
    det1.uncon?.should == true
    det1.account.amount.should == 0
    det2.amount.should == 100

    al.conciliate_account.should == true

    ac1 = det1.account
    ac2 = det2.account

    det1.account.amount.should == -100
    det2.account.amount.should == 100

    ac1.reload.amount.should == -100
    ac2.reload.amount.should == 100
  end

  scenario "Nulling an account" do
    al = AccountLedger.new_money(@params)

    al.save.should == true
    al.active.should == true

    ac1 = Account.find(@params[:account_id])
    ac2 = Account.find(@params[:to_id])
    #puts al.errors.messages
    ac1.amount.should == 0
    ac2.amount.should == 0

    UserSession.current_user = User.new{|u| u.id= 5}

    al.null_account.should == true
    al.nuller_id.should == 5
    al.nuller_datetime.kind_of?(Time).should == true

    al.account_ledger_details[0].state.should == "nulled"
    al.account_ledger_details[1].state.should == "nulled"

    al.active.should == false
    al.account_ledger_details[0].active.should == false
    al.account_ledger_details[1].active.should == false
    ac1.reload.amount.should == 0
    ac2.reload.amount.should == 0

    al.conciliate_account.should == false
  end

  scenario "Make a transference" do
    c = Cash.create!(:name => 'Cash 1', :currency_id => 2)
    c_ac_id = c.account.id
    @params[:operation] = 'trans'
    @params[:to_id] = c_ac_id
    @params[:exchange_rate] = 0.5

    al = AccountLedger.new_money(@params)

    al.save.should == true
    al.active.should == true

    ac1 = al.account
    ac2 = al.to

    ac1_amt = ac1.amount
    ac2_amt = ac2.amount

    al.account_ledger_details[0].amount.should == -100
    al.account_ledger_details[1].amount.should == 50

    al.conciliate_account.should == true

    ac1.reload.amount.should == ac1_amt - 100
    ac2.reload.amount.should == ac2_amt + 50

  end
end
