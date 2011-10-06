# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Income", "test features" do
  background do
    create_organisation_session
    create_user_session
  end

  let!(:organisation) { create_organisation(:id => 1) }
  let!(:items) { create_items }
  let(:item_ids) {Item.org.map(&:id)}
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:client) { create_client(:matchcode => 'Karina Luna') }
  let!(:tax) { Tax.create(:name => "Tax1", :abbreviation => "ta", :rate => 10)}

  let(:income_params) do
      d = Date.today
      i_params = {"active"=>nil, "bill_number"=>"56498797", "contact_id" => client.id, 
        "exchange_rate"=>1, "currency_id"=>1, "date"=>d, 
        "description"=>"Esto es una prueba", "discount" => 3, "project_id"=>1 
      }

      details = [
        { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>3, "quantity"=> 10},
        { "description"=>"jejeje", "item_id"=>2, "organisation_id"=>1, "price"=>5, "quantity"=> 20}
      ]
      i_params[:transaction_details_attributes] = details
      i_params
  end

  let(:pay_plan_params) do
    d = options[:payment_date] || Date.today
    {:alert_date => (d - 5.days), :payment_date => d,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true }.merge(options)
  end

  scenario "Should not alow repeated items" do
    data = income_params.dup
    data[:transaction_details_attributes] << { "description"=>"jejeje", "item_id"=>1, "organisation_id"=>1, "price"=>3, "quantity"=> 2}
 
    i = Income.new(data)
    i.save_trans.should be_false
    i.errors[:base].should == [ I18n.t("errors.messages.transaction.repeated_items") ]
  end
end
