# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Account Feature", "test all incomes as transference between accounts. " do

  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 1000) {|a| a.id = 1 }
    CashRegister.create!(:name => 'Cash register Bs.', :amount => 1000, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}
    CashRegister.create!(:name => 'Cash register $.', :amount => 1000, :currency_id => 2, :address => 'None') {|cr| cr.id = 3}

    Contact.create!(:name => 'karina', :last_name => 'Luna Pizarro', :matchcode => 'Karina Luna', :address => 'Mallasa') {|c| c.id = 1 }

    create_currencies
    create_currency_rates
  end

  scenario "Create a transference" do
    trans = Bank.find(1).account_ledgers.build
    trans.create_transference.should == false

    # Invalid with all fields empty
    trans.errors[:amount].should_not == blank?
    trans.errors[:to_account].should_not == blank?

    # invalid with exchange_rate empty
    trans.to_account = 3
    trans.amount = 70

    trans.create_transference.should == false
    trans.errors[:to_exchange_rate].should_not == blank?

    # invalid exchange_rate should be greater
    trans.to_exchange_rate = -2
    trans.create_transference.should == false
    trans.errors[:to_exchange_rate].should_not == blank?

    # Valid transference
    trans.to_exchange_rate = 1.0/7
    trans.create_transference.should == true
    trans.creator_id.should == 1

    User.stubs(:find => User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1})
    trans.creator.email.should == 'admin@example.com'

    AccountLedger.find(trans.id).amount.should == -70
    AccountLedger.find(trans.account_ledger_id).amount.should == (70.0/7).round(2)
    
    b1 = Account.org.find(1)
    b1.account_ledgers.size.should == 2
    b1.total_amount.should == 1000

    c2 = Account.org.find(3)
    c2.account_ledgers.size.should == 2
    b1.total_amount.should == 1000

    # Conciliation
    trans.conciliate_account
    trans.approver_id.should == 1
    b1 = Account.org.find(1)
    b1.account_ledgers.size.should == 2
    b1.total_amount.should == 930

    # Stub to test for other user
    UserSession.current_user.stubs(:id => 2)
    al2 = AccountLedger.find(trans.account_ledger_id)
    al2.conciliate_account
    al2.approver_id.should == 2
    c2 = Account.org.find(3)
    c2.account_ledgers.size.should == 2
    c2.total_amount.should == 1010
  end
end

