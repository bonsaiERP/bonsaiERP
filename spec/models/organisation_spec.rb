# require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Organisation do
  before(:each) do
    # @country = Country.new(:id => 1, :name => "Bolivia", :abbreviation => "bo", :blank? => true).stubs(:id => 1)
    @methods = {:blank? => false, :is_a? => false, :valid? => true, :destroyed? => false, :new_record? => false}

    Currency.stubs(:find).returns(stub({:id => 1, :name => "boliviano"}.merge(@methods) ))

    @taxes = [{:name => "Impuesto al Valor Agregado", :rate => 13, :abbreviation => "IVA"}, {:name => "Impuesto a las transacciones", :rate => 1.5, :abbreviation => "IT"}]
    @methods.merge({:taxes => @taxes})
    Country.stubs(:find).returns(stub({:id => 1, :name => "Bolivia"}.merge(@methods).merge({:taxes => @taxes}) ))

    Tax.stubs(:save).returns(stub(:id => 1))
#
#    @user = User.new(:id => 1, :name => "Juan", :blank? => false)
#    User.stubs(:find).returns(@user)
    @params = {:name => "ecuanime",  :country_id => 1, :currency_id => 1, :address => "Mallasa calle 4 Nº 71",
      :phone => "2745620", :mobile => "70681101",
      :email => "boris@example.com", :website => "ecuanime.net"
    }

    #@country = stub(:taxes => [], :id => 1, :valid? => true)
    #Country.stubs(:find).returns(@country)

    @user = stub(:id => 1)
    UserSession.stubs(:current_user => @user)
  end

  #it 'should test stubs' do
    #UserSession.current_user.id.should == 1
    #Country.find(1).id.should == 1
    #Country.find(1).valid?.should == true
  #end

  it 'should not allow user to be set' do
    @org = Organisation.create(@params)
    @org.user_id.should == 1
  end

  it 'should have many taxes' do
    # Organisation.any_instance.stubs(:taxes).returns([])
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
