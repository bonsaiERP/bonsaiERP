# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

feature "Test account ledger", "for in outs and transferences" do
  background do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
    @params = {
      :date => Date.today, :operation => "out",
      :account_ledger_details_attributes => [
        {:account_id => 1, :amount => 100, :reference => "In"},
        {:account_id => 2, :amount => -100, :reference => "Out"},
      ]
    }

    create_currencies
    create_account_types
    create_money_store(1, "Bank")
  end

  scenario "It should correctly assing the correct methods for money" do
    al = AccountLedger.new_money(:operation => "in", :account_id => 1)

    puts "Initialization"
    al.account_to.should == nil
    al.in?.should == true
    al.currency.to_s.should == "Bs."
    

  end
end
