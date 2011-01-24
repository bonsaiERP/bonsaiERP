require 'spec_helper'

describe Transaction do
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

  def set_transaction_taxes(*rates)
    rates = rates.any? ? rates : [13, 1.5]
    arr = []
    rates.each_with_index do |rate, i|
      arr << Object.new
      arr.last.stubs(:rate => rate, :id => i + 1)
    end
    @params["taxis_ids"] = arr.map(&:id)
    Tax.stubs(:find => arr)
    Transaction.any_instance.stubs(:taxes => arr)
  end

  it 'should have total and balance equal' do
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.should == transaction.balance
  end

  # NOT unit test
  it 'should set the values of tax and discount if nil' do
    @params["discount"] = nil
    transaction = Transaction.new(@params)
    transaction.save
    transaction.discount.should == 0
    transaction.tax_percent.should == 0
  end

  # NOT unit test
  it 'should calculate total with discount and without taxes' do
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.to_f.should == 344.35
  end

  it 'should calculate the gross total' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.gross_total.to_f.should == 355
    transaction.gross_total.should_not == transaction.total
  end

  # NOT unit test
  it 'should calculate total with taxes and set balance' do
    set_transaction_taxes
    t = Transaction.new
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total.to_f.should == 394.28075
  end

  it 'should should store the total taxes percentage' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.tax_percent.should == 14.5
  end

  it 'should calculate the taxes total' do
    set_transaction_taxes
    transaction = Transaction.new(@params)
    transaction.save
    transaction.total_taxes.to_f.should == 49.93075
  end
end
