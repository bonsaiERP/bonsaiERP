# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test account ledger", "for in outs and transferences" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    UserSession.current_user = User.new {|u| u.id = 1}

    @params = {
      :date => Date.today, :operation => "out",
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 100, :reference => "In"},
        {:account_id => 2, :amount => -100, :reference => "Out"},
      ]
    }

    create_currencies
    create_account_types
    b = create_bank(:currency_id => 1, :name => "Bank chiquito")
    @bank_ac_ic = b.account.id
    c = create_client(:matchcode => "Lucas Estrella")
    @cli_ac_id = c.account.id
  end

  scenario "It should correctly assing the correct methods for money" do

    al = AccountLedger.new_money(:operation => "in", :account_id => 1)

    al.to_id.should == nil
    al.in?.should == true
    al.account.currency_symbol.should == "Bs."

    al = AccountLedger.new_money(:operation => "in", :account_id => 1, :to_id => @cli_ac_id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true

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

    det1.account.amount.should == -100
    det2.account.amount.should == 100
  end
end
