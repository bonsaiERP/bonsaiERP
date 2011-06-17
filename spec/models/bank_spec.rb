require 'spec_helper'

describe Bank do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    Currency.create!(:symbol => 'Bs.', :name => 'Boliviano') {|c| c.id = 1}
    @params = {:currency_id => 1, :name => 'Banco 1', :number => '12365498', :address => 'Uno', :amount => 100}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      a = AccountType.create(y) {|a| 
        a.organisation_id = 1
        a.account_number = y[:account_number]
      }

    end
  end

  it { should have_valid(:number).when('121', '121hjs121') }

  it { should_not have_valid(:number).when('', '12')}

  it { should_not have_valid(:currency_id).when(10) }
  it { should have_valid(:currency_id).when(1) }

  it 'should create an instance' do
    Bank.create!(@params)
  end

  it 'should set original type' do
    b = Bank.create!(@params)

    b.account.original_type.should == "Bank"
  end

  it 'should check it is bank' do
    b = Bank.create!(@params)
    b.bank?.should == true
    b.cash?.should == false
  end

  it 'should create a bank account' do
    b = Bank.create!(@params)
    b.account.should_not == blank?

    b.account.currency_id.should == b.currency_id
  end

  it 'should use the bank currency' do
    Currency.create(:symbol => 'Bs.', :name => 'Boliviano') {|c| c.id = 5}
    @params[:currency_id] = 5

    b = Bank.create!(@params)
    b.account.should_not == blank?

    b.account.currency_id.should == 5
  end

  # NOT UNIT Test
  it 'should create an entrance in case it has amount' do
    b = Bank.create(@params)
    b.account.initial_amount.should == 100
    b.account.amount.should == 100
    b.account.account_type.account_number.should == "Bank"
  end

  it 'should create related account_currency' do

    b = Bank.new(@params)
    
    b.save.should == true

    b.account.amount_currency(1).should == 100
    b.account.to_s.should == b.to_s

    o_name = b.to_s

    b.name = "Other bank"
    b.save.should == true
    b.to_s.should_not == o_name
    b.account.to_s.should == b.to_s
  end
end

