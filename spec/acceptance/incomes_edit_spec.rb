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
        "description"=>"Esto es una prueba", "discount" => 0, "project_id"=>1 
      }

      details = [
        { "description"=>"jejeje", "item_id"=>1, "price"=>3, "quantity"=> 10},
        { "description"=>"jejeje", "item_id"=>2, "price"=>5, "quantity"=> 20}
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

  scenario "Edit a income and save history" do
    i = Income.new(income_params)
    i.save_trans.should be_true

    i.balance.should == 3 * 10 + 5 * 20
    i.total.should == i.balance
    i.should be_draft
    i.transaction_histories.should be_empty
    i.modified_by.should == UserSession.user_id

    # Approve de income
    i.approve!.should be_true
    i.should_not be_draft
    i.should be_approved


    i = Income.find(i.id)
    #p = i.new_payment(:account_id => bank_account.id, :base_amount => i.balance, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    #i.save_payment
    #i.reload

    #p.should be_persisted
    #i.balance.should == 0
    #p.conciliate_account.should be_true
    #
    #bank_account.reload
    #bank_account.amount.should == p.amount
    ## Diminish the quantity in edit and the amount should go to the client account
    #i = Income.find(i.id)
    edit_params = income_params.dup
    edit_params[:transaction_details_attributes][0][:id] = i.transaction_details[0].id

    edit_params[:transaction_details_attributes][1][:id] = i.transaction_details[1].id
    edit_params[:transaction_details_attributes][1][:quantity] = 5
    i.attributes = edit_params
    i.save_trans.should be_true
    i.reload
    
    i.transaction_histories.should_not be_empty
    hist = i.transaction_histories.first
    hist.user_id.should == i.modified_by

    i.transaction_details[1].quantity.should == 5
    i.balance.should == 3 * 10 + 5 * 5

    hist.data[:transaction_details][0][:quantity]
    income_params[:transaction_details_attributes].each_with_index do |det, i|
      hist.data[:transaction_details][i][:item_id].should == det[:item_id]
      hist.data[:transaction_details][i][:quantity].should == det[:quantity]
      hist.data[:transaction_details][i][:price].should == det[:price]
    end

    #puts i.account_ledgers.last.reference
    #puts i.account_ledgers.last.persisted?
    #puts i.account_ledgers.last.errors.messages

    #ac = client.account_cur(i.currency_id)
    #ac.amount.should == i.balance - 5 * 15
  end
end
