# require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    @methods = {:blank? => false, :is_a? => false, :valid? => true, :destroyed? => false, :new_record? => false}

    Currency.stubs(:find).returns(stub({:id => @@spec_uuid, :name => "boliviano"}.merge(@methods) ) )

    @taxes = [{:name => "Impuesto al Valor Agregado", :rate => 13, :abbreviation => "IVA"}, {:name => "Impuesto a las transacciones", :rate => 1.5, :abbreviation => "IT"}]
    @methods.merge({:taxes => @taxes})
    Country.stubs(:find).returns(stub({:id => @@spec_uuid, :name => "Bolivia"}.merge(@methods).merge({:taxes => @taxes}) ))

    Tax.stubs(:save).returns(stub(:id => @@spec_uuid))
    @params = {:name => "ecuanime",  :country_id => 1, :currency_id => 1, :address => "Mallasa calle 4 Nº 71",
      :phone => "2745620", :mobile => "70681101",
      :email => "boris@example.com", :website => "ecuanime.net"
    }


    @user = stub(:id => @@spec_uuid)
    UserSession.stubs(:current_user => @user)
  end

  it 'should not allow user to be set' do
    @org = Organisation.create(@params)
    @org.user_id.should == @@spec_uuid
  end

  it 'should have many taxes' do
    @org = Organisation.create(@params)
    @org.taxes.count == 2
  end

  it 'should have taxes with Tax class' do
    @org = Organisation.create(@params)
    @org.taxes.first.class.should == Tax
  end

  it 'should create links' do
    @org = Organisation.create(@params)
    @org.links.first.class.should == Link
  end

end
