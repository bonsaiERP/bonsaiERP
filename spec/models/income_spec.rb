require 'spec_helper'

describe Income do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
    @params = {"active"=>nil, "bill_number"=>"56498797", "contact_id"=>1, 
      "currency_exchange_rate"=>1, "currency_id"=>1, "date"=>'2011-01-24', 
      "description"=>"Esto es una prueba", "discount"=>3, "project_id"=>1, 
      "ref_number"=>"987654"
    }
    @details = [
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>15.5, "quantity"=> 10},
      { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>10, "quantity"=> 20}
    ]
    @params[:transaction_details_attributes] = @details
  end

  it 'should set the income to draft' do
    i = Income.create(@params)
    i.state.should == "draft"
  end

  # NOT Test Unit
  #it 'should create a pay method' do
  #  i = Income.create(@params)
  #  i.pay_plans.first.amount.should == i.total
  #  # Test the date
  #  i.pay_plans.first.payment_date.should == i.date
  #  i.pay_plans.first.alert_date.should == i.date
  #  i.pay_plans.first.organisation_id.should == i.organisation_id
  #  i.pay_plans.first.ctype.should == i.class.to_s
  #  i.pay_plans.first.currency_id.should == i.currency_id
  #  i.pay_plans.first.email.should == false
  #  i.pay_plans.first.paid.should == false
  #end

  it 'should return a correct state based on the languagge and cache values' do
    I18n.locale = :es
    i = Income.new
    i.state = 'draft'
    i.show_state.should == "Borrador"
    # Cached
    I18n.locale = :en
    i.show_state.should_not == "Draft"
  end

  it 'should retrun Draf for english' do
    I18n.locale = :en
    i = Income.new
    i.state = 'draft'
    i.show_state.should == "Draft"
    # Set to default languagge
    I18n.locale = :es
  end
end
