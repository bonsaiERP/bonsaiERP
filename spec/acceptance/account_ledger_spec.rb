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
    c = create_client(:matchcode => "Lucas Estrella")
    @cli_ac_id = c.account.id
  end

  scenario "It should correctly assing the correct methods for money" do

    al = AccountLedger.new_money(:operation => "in", :account_id => 1)

    al.to_id.should == nil
    al.in?.should == true
    al.account.currency_symbol.should == "Bs."

    puts "Save account ledger"

    al = AccountLedger.new_money(:operation => "in", :account_id => 1, :to_id => @cli_ac_id, :amount => 100, :reference => "Check 1120012" )
    al.valid?
    puts al.errors.messages
    al.save.should == true

  end
end
