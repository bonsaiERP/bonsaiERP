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
  it 'should create a pay method' do
    i = Income.create(@params)
  end
end
