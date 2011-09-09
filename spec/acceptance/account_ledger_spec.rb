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
  end

  let!(:client) { create_client(:matchcode => "Lucas Estrella")}


  let!(:bank) {create_bank(:currency_id => 1, :name => "Bank chiquito")}
  let(:bank_account) { bank.account }
  let(:bank_ac_id){ bank_account.id }

  let(:valid_params){ 
    {
      :date => Date.today, :operation => "in", :reference => "For more", :amount => 100,
      :account_id => bank_ac_id, :contact_id => client.id
    }
  }

  scenario "It should correctly assing the correct methods for money" do

    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id)

    ac = client.accounts.first

    al.should be_in

    al.account.currency_symbol.should == "Bs."
    al.active.should == true

    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id, :contact_id => client.id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true

    al.active.should == true

    al.creator_id.should == 1

    al.currency_id.should == 1
    al.amount.should == 100
    al.conciliation.should == false

    al.account.original_type.should == "Bank"
    al.to_id.should == ac.id
    al.to.original_type.should == "Client"

    UserSession.current_user = User.new{|u| u.id= 2}

    al.conciliate_account

    al.conciliation.should == true
    al.reload

    al.approver_id.should == 2
    al.approver_datetime.kind_of?(Time).should == true
    al.account_balance.should == 100
    al.to_balance.should == -100

    al.account.amount.should == 100
    al.to.amount.should == -100

  end

  scenario "It should create amount between two different currencies" do
    b = create_bank(:currency_id => 2)
    b.account.currency_id.should == 2

    al = AccountLedger.new_money(:operation => "in", :account_id => b.account.id, :contact_id => client.id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true

    al.reload
    al.to.original_type.should == "Client"
    client.reload
    client.accounts.size.should == 2

    al.account.amount.should == 0
    al.to.amount.should == 0

    al.conciliate_account.should be_true
    al.reload

    al.account.amount.should == 100
    al.to.amount.should == -100
  end

  scenario "It should create an out" do
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id,              
           :contact_id => client.id, :amount => 100, :reference => "Ledger 123" )

    al.save.should be_true

    al.conciliate_account.should be_true

    al.reload
    al.account.amount.should == 100

    al2 = AccountLedger.new_money(:operation => "out", :account_id => bank_ac_id,              
           :contact_id => client.id, :amount => 100, :reference => "Ledger out 123" )

    al2.save.should be_true

    al2.organisation_id.should == 1
    al2.amount.should == -100
    al2.operation.should == "out"

    al2.account.amount == 100
    al2.to.amount == 0

    al2.conciliate_account#.should == true
    al2.reload

    al2.account.amount == -100
    al2.to.amount == -100
  end

  scenario "Nulling an account" do
    al = AccountLedger.new_money(valid_params)

    al.save.should == true
    al.active.should == true

    UserSession.current_user = User.new{|u| u.id= 5}

    al.null_transaction.should == true
    al.nuller_id.should == 5
    al.nuller_datetime.kind_of?(Time).should == true

    al.active.should == false
    al.reload

    al.account.amount.should == 0
    al.to.amount.should == 0

    al.conciliate_account.should == false
  end

  scenario "Make a transference" do

    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id,              
           :contact_id => client.id, :amount => 100, :reference => "Check 1120012" )
    al.save.should be_true
    al.conciliate_account

    c = Cash.create!(:name => 'Cash 1', :currency_id => 2)
    c_ac_id = c.account.id
    valid_params[:operation] = 'trans'
    valid_params[:to_id] = c_ac_id
    valid_params[:exchange_rate] = 0.5

    al = AccountLedger.new_money(valid_params)

    al.save.should be_true
    al.reload
    al.active.should == true
    al.currency_id.should == 1

    al.account.amount.should == 100
    al.to.amount.should == 0

    al.conciliate_account#.should == true

    al.reload

    al.account.amount.should == 0
    al.to.amount.should == 50

  end

  scenario "Make serveral in/outs for one account and check that the balance is right" do
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id, :contact_id => client.id, :amount => 100, :reference => "Check 1120012" )
    al.save.should == true

    al.conciliate_account.should be_true
    al.reload

    al.account_balance.should == 100
    al.to_balance.should == -100

    al = AccountLedger.new_money(:operation => "in", :account_id => bank_ac_id, :contact_id => client.id, :amount => 100, :reference => "Check 1120013" )
    al.save.should == true

    al.conciliate_account.should be_true
    al.reload

    al.account_balance.should == 200
    al.to_balance.should == -200

    al = AccountLedger.new_money(:operation => "out", :account_id => bank_ac_id, :contact_id => client.id, :amount => 55.55, :reference => "Check 1120014" )
    al.save.should == true

    al.conciliate_account.should be_true
    al.reload

    al.account_balance.should == 200 - 55.55
    al.to_balance.should == -200 + 55.55

    # Create a bank with another currency
    b = create_bank(:currency_id => 2, :amount => 1000)
    b.account.currency_id.should == 2
    b.account_amount.should == 1000

    Account.find(bank_ac_id)

    al = AccountLedger.new_money(:operation => "trans", :account_id => b.account.id, :to_id => 10, :amount => 100, :reference => "Check 1120012", :exchange_rate => 2.00 )

    al.save.should be_false
    al.errors[:to_id].should_not be_empty

    # Other error
    al = AccountLedger.new_money(:operation => "trans", :account_id => b.account.id, :to_id => b.account.id, :amount => 100, :reference => "Check 1120012", :exchange_rate => 2.00 )

    al.save.should be_false
    al.errors[:base].should_not be_empty


    al = AccountLedger.new_money(:operation => "trans", :account_id => b.account.id, :to_id => bank_ac_id, :amount => 100, :reference => "Check 1120012", :exchange_rate => 2.00 )
    al.save.should be_true

    al.should be_persisted
    al.reload
    al.conciliate_account

    al.reload

    al.account_balance.should == 1000 - 100
    al.to_balance.should == 200 - 55.55 + 100 * 2
    
  end

  scenario "Do not allow outs if the amount is not available" do
    amt = bank_account.amount + 10
    al = AccountLedger.new_money(:operation => "out", :account_id => bank_ac_id,              
           :contact_id => client.id, :amount => amt, :reference => "Check 1120012" )

    al.save.should be_false
    al.errors[:base].should_not be_blank
    al.errors[:amount].should_not be_blank
  end
end
