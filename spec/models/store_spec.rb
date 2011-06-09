require 'spec_helper'

describe Store do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    @params = {:name => 'Store 1', :address => 'Los Pinos Bloque 80 dpto. 201'}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      a = AccountType.create(y) {|a| 
        a.organisation_id = 1
        a.account_number = y[:account_number]
      }
    end
  end

  it 'should create' do
    Store.create!(@params)
  end

  it 'should create and account' do
    s = Store.create!(@params)

    s.account.persisted?.should == true
    s.account.amount.should == 0
    s.account.initial_amount == 0
    s.account.currency_id.should == OrganisationSession.currency_id
    s.account.account_type.account_number.should == "Store"
  end
end
