require 'spec_helper'

describe Cash do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')

    Currency.create!(:symbol => 'Bs.', :name => 'Boliviano') {|c| c.id = 1}
    @params = {:currency_id => 1, :name => 'Caja 1', :number => '12365498', :address => 'Uno'}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      AccountType.create!(y) {|a|
        a.organisation_id = 1
        a.account_number = y[:account_number]
      }
    end
  end

  it { should_not have_valid(:name).when('No') }

  it { should_not have_valid(:currency_id).when(2) }
  it { should have_valid(:currency_id).when(1) }

  it 'should create an instance' do
    c = Cash.create!(@params)
  end

  it 'should check it is cash' do
    c = Cash.create(@params)
    c.cash?.should == true
    c.bank?.should == false
  end

  it 'should assisn amount to cash' do
    @params[:amount] = 200
    c = Cash.create!(@params)

    c.account_amount.should == 200
    c.account_currency_id.should == 1
    c.account_name.should == c.to_s
  end
end


