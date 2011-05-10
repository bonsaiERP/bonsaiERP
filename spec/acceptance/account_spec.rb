# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Account Feature", "test all incomes as transference between accounts. " do

  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    UserSession.current_user = User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1}

    b = Bank.create!(:number => '123', :currency_id => 1, :name => 'Bank JE', :amount => 1000) {|a| a.id = 1 }
    b.account_ledgers.first.conciliate_account

    c1 = CashRegister.create!(:name => 'Cash register Bs.', :amount => 1000, :currency_id => 1, :address => 'Uno') {|cr| cr.id = 2}
    c1.account_ledgers.first.conciliate_account

    c2 = CashRegister.create!(:name => 'Cash register $.', :amount => 1000, :currency_id => 2, :address => 'None') {|cr| cr.id = 3}
    c2.account_ledgers.first.conciliate_account

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
    trans.date = Date.today

    trans.create_transference.should == true
    trans.creator_id.should == 1

    User.stubs(:find => User.new(:id => 1, :email => 'admin@example.com') {|u| u.id = 1})
    trans.creator.email.should == 'admin@example.com'

    AccountLedger.find(trans.id).amount.should == -70
    AccountLedger.find(trans.account_ledger_id).amount.should == (70.0/7).round(2)

    # Conciliate should conciliate the two sides of transference
    trans.conciliate_account

    trans.reload
    trans.conciliation.should == true
    trans.transferer.conciliation.should == true
    
    b1 = Account.org.find(1)
    b1.account_ledgers.size.should == 2
    b1.total_amount.should == 930

    c2 = Account.org.find(3)
    c2.account_ledgers.size.should == 2
    c2.total_amount.should == 1010

    # Conciliation
    #trans.conciliate_account
    #trans.approver_id.should == 1
    #b1 = Account.org.find(1)
    #b1.account_ledgers.size.should == 2
    #b1.total_amount.should == 930

    # Stub to test for other user
    UserSession.current_user.stubs(:id => 2)
    al2 = AccountLedger.find(trans.account_ledger_id)
    al2.conciliate_account
    al2.approver_id.should == 2
    c2 = Account.org.find(3)
    c2.account_ledgers.size.should == 2
  end


  scenario "Do not exeed the max amount, and control conciliation" do
    trans = Bank.find(1).account_ledgers.build(:to_account => 2, :amount => 1100)
    trans.create_transference.should == false

    trans.errors[:amount].should_not == blank?

    # Create an unconciliated amount
    trans.amount = 1000
    trans.date = Date.today
    trans.create_transference.should == true
    trans.conciliation.should == false

    # Create an outcome
    al = Bank.find(1).account_ledgers.build(:amount => 500, :income => false, :date => Date.today, :contact_id => 2, :reference => '123456789')
    al.save.should == true
    al.conciliate_account.should == true

    # Conciliation of the first transference and check amount
    trans.reload# = AccountLedger.find(trans.id)

    trans.conciliate_account.should == false
    trans.errors.should_not == blank?
    puts trans.errors
    trans.conciliation.should == false
  end

  scenario "an error on one side should not allow to save transference conciliation" do
    trans = Bank.find(1).account_ledgers.build(:to_account => 2, :amount => 100)
    
    trans.transferer.stubs(:conciliate_account => false)
    trans.transferer.stubs(:errors => {:base => ["Jeje"]})

    trans.conciliate_account.should == false
    trans.transferer.errors[:base].should_not == blank?
  end

  scenario "deleting one side of the account_ledger should delete the other side" do
    trans = Bank.find(1).account_ledgers.build(:amount => 100, :to_account => 2, :date => Date.today)
    trans.create_transference.should == true
    trans.account_ledger_id.should_not == blank?

    ac2_id = trans.account_ledger_id

    trans.destroy.destroyed?.should == true
    AccountLedger.where(:id => ac2_id).size.should == 0
  end



  scenario "deleting one side with error the account_ledger should not delete the other side" do
    trans = Bank.find(1).account_ledgers.build(:amount => 100, :to_account => 2, :date => Date.today)
    trans.create_transference.should == true
    trans.account_ledger_id.should_not == blank?

    ac2_id = trans.account_ledger_id
    t2 = trans.transferer
    t2.stubs(:destroyed? => false)
    t2.stubs(:delete => t2)

    trans.destroy

    trans.destroyed?.should == false
    AccountLedger.where(:id => trans.id).size.should == 1
    AccountLedger.where(:id => ac2_id).size.should == 1
  end

end

