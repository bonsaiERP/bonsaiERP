require 'spec_helper'

describe AccountBalance do
  let!(:currency) { Currency.create!(name: "Nun", symbol: "&&") }
  before do
    AccountType.stub!(find_by_account_number: stub(id: 1) )
    OrganisationSession.stub!(currency_id: currency.id)
    UserSession.stub!(user_id: 10)
  end

  let!(:contact) { Client.create!(matchcode: "Jhon Smith") }

  it 'should have an account' do
    contact.accounts.size.should == 1
    contact.account_cur(currency.id).amount.should == 0
  end

  it 'should not allow if is not a contact' do
    account_balance = AccountBalance.new(amount: 10, currency_id: currency.id, contact_id: 10000)
    account_balance.save.should be_false
    account_balance.errors[:contact].should_not be_blank
  end

  it 'should update the balance for default currency' do
    account_balance = AccountBalance.new(amount: 10, currency_id: currency.id, contact_id: contact.id)
    account_balance.save.should be_true

    account_balance.user_id.should == UserSession.user_id
    account_balance.old_amount.should == 0
    account_balance.amount.should == 10

    ac = contact.account_cur(currency.id)
    ac.amount.should == 10
    ac.accountable_type.should == "Contact"
    ac.original_type.should == "Client"
  end

  it 'should update the balance for default currency negative value' do
    account_balance = AccountBalance.new(amount: -20, currency_id: currency.id, contact_id: contact.id)
    account_balance.save.should be_true

    ac = contact.account_cur(currency.id)
    ac.amount.should == -20
    ac.accountable_type.should == "Contact"
    ac.original_type.should == "Client"
  end

  it 'should update the old amount' do
    Account.any_instance.stub(amount: 10)
    
    account_balance = AccountBalance.new(amount: 50, currency_id: currency.id, contact_id: contact.id)
    account_balance.save.should be_true
    
    account_balance.user_id.should == UserSession.user_id
    account_balance.old_amount.should == 10
    account_balance.amount.should == 50
  end

  it 'should update the balance with other currencies that not exists' do
    cur2 = Currency.create!(name: "Other", symbol: "JJ")
    account_balance = AccountBalance.new(amount: 10, currency_id: cur2.id, contact_id: contact.id)
    account_balance.save#.should be_true

    ac = contact.account_cur(cur2.id)
    ac.amount.should == 10
    ac.accountable_type.should == "Contact"
    ac.original_type.should == "Client"
    ac.currency_id = cur2.id
  end

  it 'should update the balance with other currencies that not exists with negative value' do
    cur2 = Currency.create!(name: "Other", symbol: "JJ")
    account_balance = AccountBalance.new(amount: -100, currency_id: cur2.id, contact_id: contact.id)
    account_balance.save#.should be_true

    ac = contact.account_cur(cur2.id)
    ac.amount.should == -100
    ac.accountable_type.should == "Contact"
    ac.original_type.should == "Client"
    ac.currency_id = cur2.id
  end
end
