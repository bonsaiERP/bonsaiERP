require 'spec_helper'

describe Store do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)

    @params = {:currency_id => 1, :name => 'Banco 1', :number => '12365498', :address => 'Uno', :amount => 100}

    YAML.load_file( File.join(Rails.root, "db/defaults/account_types.#{I18n.locale}.yml") ).each do |y|
      a = AccountType.create(y) {|a| 
        a.organisation_id = 1
        a.account_number = y[:account_number]
      }
    end
  end
end
