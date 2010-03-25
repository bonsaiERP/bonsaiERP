require 'spec_helper'

describe Organisation do
  before(:each) do
    @country = mock_model(Country, :id => 1, :name => "Bolivia", :abbreviation => "bo")
    @user = mock_model(User, :id => 1 )
    @params = {:name => "ecuanime", :user_id => 1,
      :country_id => 1, :address => "Mallasa calle 4 Nº 71",
      :phone => "2745620", :mobile => "70681101",
      :email => "boris@example.com", :website => "ecuanime.net"
    }
  end

  it 'should create a valid organisation' do
    Organisation.create!(@params)
  end

  it 'should add ' do
    
  end
end
