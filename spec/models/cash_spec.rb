require 'spec_helper'

describe Bank do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')

    @params = {:currency_id => 1, :name => 'Caja 1', :number => '12365498', :address => 'Uno'}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      a = AccountType.new(y)
      a.organisation_id = 1
      a.account_number = y[:account_number]
    end
  end

  it 'should create an instance' do
    Cash.create!(@params)
  end

  it 'should check it is cash' do
    c = Cash.create(@params)
    c.cash?.should == true
    c.bank?.should == false
  end
end


