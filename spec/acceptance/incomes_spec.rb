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
  let!(:bank) { create_bank(:number => '123', :amount => 0) }
  let(:bank_account) { bank.account }
  let!(:client) { create_client(:matchcode => 'Karina Luna') }

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
     :interests_penalties => 0,
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

  scenario "Create a payment with nearest pay_plan" do

    log.info "Creating new income"
    i = Income.new(income_params)

    i.should be_cash
    i.save_trans.should be_true
    i.should be_draft
    i.deliver.should be_false
    i.delivered.should be_false

    i.reload
    log.info "Checking details, cash and balance for income"
    i.transaction_details.size.should == 2
    i.should be_cash
    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total
    i.total_currency.should == i.total
    i.should be_draft

    log.info "Checking income details"
    i.transaction_details[0].balance.should == 10
    i.transaction_details[0].original_price.should == 3
    i.transaction_details[1].balance.should == 20
    i.transaction_details[1].original_price.should == 5

    a1 = Account.find(i.account.id)
    a1.accountable.should == client
    a1.amount.should == 0
    a2 = Account.org.find_by_original_type("Income")
    a2.amount.should == 0

    i.approve!.should == true
    i.reload
    i.approver_id.should == 1
    i.should be_approved

    # Create a payment
    i.payment?.should == false

    p = i.new_payment(:account_id => bank_account.id, :amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    p.class.should == AccountLedger
    p.payment?.should == true
    p.operation.should == 'in'
    p.amount.should == 30
    p.interests_penalties.should == 0

    i.payment?.should == true

    bal = i.balance

    i.save_payment.should == true
    p.reload
    p.to_id.should == Account.org.find_by_original_type(i.class.to_s).id
    p.description.should_not == blank?
    p.amount.should == 30

    i.balance.should == bal - 30
    p.persisted?.should be_true

    p.account.original_type.should == "Bank"
    p.to.original_type.should == "Income"

    p.account.amount.should == 0
    p.to.amount.should == 0

    p.conciliate_account.should be_true
    p.reload

    p.approver_id.should == UserSession.user_id
    p.approver_datetime.kind_of?(Time).should == true

    p.account.amount.should == 30
    p.to.amount.should == - 30

    i.deliver.should == false
    
    p = i.new_payment(:account_id => bank_account.id, :amount => i.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

    i.save_payment.should == true

    p.conciliation.should == false
    i.should be_paid

    # Conciliation
    p.conciliate_account.should == true
    p.reload

    p.conciliation.should == true
    i.reload
    i.balance.should == 0
    i.deliver.should be_false

    p.conciliation.should be_true
    p.reload

    p.account.amount.should == i.total
    p.to.amount.should == -i.total

    i.deliver = true
    i.save
    i.reload
   
    i.deliver.should be_true 
  end

  scenario "Create a an income with credit" do
    i = Income.new(income_params)
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    # Create PayPlan
    d = Date.today
    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30)
    pp.should == false

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.reload
    i.cash.should == false
    i.pay_plans.should have(1).element #size.should == 1
    i.pay_plans.first.amount.should == i.balance
    i.payment_date.should == i.pay_plans.first.payment_date
    
    i.credit?.should == true
    i.creditor_id.should == UserSession.user_id
    i.credit_datetime.should_not == blank?

    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30)

    pp.transaction_id.should == i.id
    pp.currency_id.should == i.currency_id

    i.save_pay_plan.should == true
    i.reload
    i.pay_plans.should have(2).elements
    i.payment_date.should == i.pay_plans.first.payment_date

    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    i.new_pay_plan(:payment_date => d + 1.month, :alert_date => d - 5.days, :amount => 30, :repeat => "1")
    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.first.payment_date.should == d
    i.pay_plans.size.should == (i.balance/30).ceil
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # delete many pay_plans
    pp_ids = i.pay_plans[2..i.pay_plans.size].map(&:id)
    i.destroy_pay_plans(pp_ids).should == true
    i.reload

    i.pay_plans.size.should == 2
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    pp = i.pay_plans.last
    i.new_pay_plan(:payment_date => pp.payment_date, :alert_date => pp.alert_date, :amount => 30, :repeat => "true")
    i.save_pay_plan.should == true

    i.pay_plans.unpaid.size.should == (i.balance/30).ceil
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # Create a payment
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234')
    # Payment should have the amount of the first unpaid pay_plan
    p.interests_penalties.should == 0
    p.amount.should == 30

    i.save_payment.should == true
    p.should be_persisted
    i.reload
    
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 1
    i.balance.should == i.total - 30
    i.payment_date.should.should == i.pay_plans.unpaid.first.payment_date

    p.reload
    p.amount.should == 30
    p.account.amount.should == 0
    p.to.amount.should == 0

    p.conciliate_account.should == true

    p.reload
    p.should be_conciliation
    
    p.account.amount.should == 30
    p.to.amount.should == -30

    # Payment that is nulled
    bal = i.balance
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234')
    p.interests_penalties.should == 0

    i.save_payment.should == true
    i.reload
    i.balance.should == bal - 30
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 2
    p.conciliation.should == false
    p.reload

    p.null_transaction.should == true
    i.reload

    i.balance.should == bal
    i.pay_plans.unpaid.size.should ==  (i.total/30).ceil - 1
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    bal = i.balance
    size = i.pay_plans.unpaid.count
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :amount => 45)
    
    i.save_payment.should == true
    p.conciliate_account.should == true
    i.reload

    i.pay_plans.unpaid.size.should == size - 1
    i.balance.should == bal - 45

    p.reload
    p.account.amount.should == 30 + 45
    p.to.amount.should == -(30 + 45)

    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :amount => i.balance)
    
    i.save_payment.should == true

    i.reload
    i.pay_plans.unpaid.size.should == 0
    i.balance.should == 0
    p.conciliate_account.should == true

    p.reload

    p.account.amount.should == i.total
    p.to.amount.should == -i.total
    
  end

  scenario "Create credit with interests" do
    i = Income.new(income_params)
    i.save_trans.should == true

    i.approve!.should == true

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.pay_plans.unpaid.size.should == 1
    i.pay_plans.first.amount.should == i.balance

    d = Date.today

    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30, :interests_penalties => i.balance/10, :repeat => "1")

    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).ceil
    
    i.pay_plans[0].interests_penalties.should == (i.balance/10).round(2)
    i.pay_plans[1].interests_penalties.should == ((i.balance - 30)/10).round(2)
    i.pay_plans[2].interests_penalties.should == ((i.balance - 60)/10).round(2)

    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # edit pay_plan
    pp = i.pay_plans[1]
    pp_last = i.pay_plans.last
    amt = pp_last.amount + pp.amount
    int = pp_last.interests_penalties + pp.interests_penalties
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date,
                    :amount => amt , :interests_penalties => int)
    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).floor
    i.pay_plans[1].id.should == pp.id
    i.pay_plans[1].amount.should == amt
    
    # edit second pay_plan and repeat pattern
    pp = i.pay_plans[1]
    
    #i.pay_plans.each {|pp| puts "#{pp.id} #{pp.amount} #{pp.interests_penalties}" }
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date,
                    :amount => 60, :interests_penalties => 50, :repeat => true)
    i.save_pay_plan.should == true
    i.reload
    i.pay_plans.size.should == ( (i.balance - 30)/60 ).ceil + 1

    i.pay_plans[1].interests_penalties.should == 50
    int_per = 50/( i.balance - i.pay_plans[0].amount )
    i.pay_plans[2].interests_penalties.should == (int_per * (i.balance - 90) ).round(2)
  end

  scenario "Make payment with a contact account" do
    i = Income.new(income_params)
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should be_true

    # Make a deposit
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => i.balance, :reference => "Check 1120012" )
    al.save.should == true
    al.conciliate_account.should == true

    client.account_cur(1).amount.should == -i.balance

    i.reload
    log.info "Creating payment without exchange_rate"
    p = i.new_payment(:account_id => client.account_cur(1).id, :reference => 'Test for client', :exchange_rate => 1)

    p.amount.should == i.balance
    p.amount.should == -p.account.amount

    i.save_payment.should be_true
    i.balance.should == 0
    p.reload

    p.conciliation.should be_false
    p.send(:make_conciliation?).should be_true

    i18ntrans = I18n.t("transaction.#{i.class}")
    txt = I18n.t("account_ledger.payment_description", 
      :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
      :ref => "#{i.ref_number}", :account => p.account_name
    )
    p.description.should == txt

    # conciliate
    p.conciliate_account.should be_true
    client.reload

    p.account.amount.should == 0
    client.account_cur(1).amount.should == 0

    p.account.amount.should == 0
    client.reload
    client.account_cur(1).amount.should == 0

  end

  scenario "Pay with a differen curency" do
    i = Income.new(income_params.merge(:discount => 0))
    i.save_trans.should == true
  
    i.approve!.should == true

    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0

    p = i.new_payment(:account_id => new_bank_account.id, :amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should be(true)
    i.reload
    i.account_ledgers.first.amount.should == 30
    i.balance.should == i.total - 2 * 30
    p.reload

    p.account.amount.should == 0
    p.to.amount.should == 0

    p.conciliate_account.should be(true)
    p.reload

    p.account.amount.should == 30
    p.account_original_type.should == "Bank"
    p.to.amount.should == -2 * 30

    p = i.new_payment(:account_id => new_bank_account.id, :amount => 30, :interests_penalties => 1,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    p.amount.should == 31
    p.interests_penalties.should == 1
    i.save_payment.should be(true)
    p.conciliate_account.should be(true)

    i.reload
    i.account_ledgers.first.amount.should == 30
    i.balance.should == i.total - 2 * 60

    p.reload
    p.account.amount.should == 61
    p.to.amount.should == -(30 + 31) * 2

    log.info "Pay with contact account and with interests penalties"

    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :contact_id => client.id, :amount => 100, :reference => "Other currency check")
    al.save.should be(true)
    al.conciliate_account.should be(true)
    al.reload
    
    al.to.amount.should == -100
    i.reload

    bal = i.balance
    p = i.new_payment(:account_id => al.to_id, :amount => i.balance/2, :interests_penalties => 1,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should be(true)
    i.reload

    i.balance.should == 0

    p.conciliate_account.should be(true)
    p.reload

    p.conciliation.should be(true)
    p.account.amount.should == -100 + bal/2 + 1

  end

  scenario "Make payment with a contact account and with different currency" do
    i = Income.new(income_params)
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true

    d = Date.today
    i.new_pay_plan(:amount => 30, :repeat => true, :payment_date => d, :alert_date => d - 5.days)
    i.save_pay_plan.should == true
    i.pay_plans.size.should == (i.balance/30).ceil

    # bank creation and client deposits in another currency
    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0

    client.accounts.should have(1).element

    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :contact_id => client.id, :amount => 200, :reference => "Other currency check")

    client.reload

    al.save.should == true
    client.accounts.should have(2).elements
    al.conciliate_account.should == true

    client.reload
    client.account_cur(2).amount.should == -200

    new_bank_account.reload
    new_bank_account.amount.should == 200

    log.info("Paying from account with different currency")
    p = i.new_payment(:account_id => al.to_id, :amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')
    i.save_payment.should == true
    p.should be_persisted

    income_account = Account.org.find_by_original_type("Income")
    
    log.info("Set the correct description for a payment with other currency")
    c1 = Currency.find(i.currency_id)
    c2 = Currency.find(p.currency_id)

    i18ntrans = I18n.t("transaction.#{i.class}")
    txt = I18n.t("account_ledger.payment_description", 
      :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
      :ref => "#{i.ref_number}", :account => p.account_name
    )
    txt << " " << I18n.t("currency.exchange_rate",
      :cur1 => "#{c1.symbol} 1" , 
      :cur2 => "#{ p.currency_symbol } 2,00"
    )

    p.description.should == txt
    p.should_not be_conciliation

    i.balance.should == i.total - 30 * 2

    p.conciliate_account.should be_true
    p.reload
    client.reload

    client.account_cur(2).amount.should == -200 + 30
    #income_account.cur(2).amount.should == -30

    i.reload
    i.pay_plans.unpaid.size.should == ( (i.total - 30)/30 ).ceil
    i.pay_plans.paid.size.should == 1
    i.pay_plans_total.should == i.total - 30
  end

  scenario "check different updates and modifications to pay_plans" do
    i = Income.new(income_params)
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    # Create PayPlan
    d = Date.today

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.reload
    i.cash.should be(false)
    i.pay_plans.size.should == 1
    i.pay_plans.first.amount.should == i.balance
    i.payment_date.should == i.pay_plans.first.payment_date

    pp = i.pay_plans.first
    i.edit_pay_plan(pp.id, :amount => 30, :payment_date => d - 3.days, :alert_date => d - 8.days, :repeat => true)

    i.save_pay_plan.should be(true)
    i.reload
    i.pay_plans.first.payment_date.should == d - 3.days
    i.pay_plans.first.alert_date.should == d - 8.days

    i.pay_plans.size.should be( ( i.balance/30 ).ceil )

    pp = i.pay_plans[2]
    options = pp.attributes.merge(:amount => 40)
    i.edit_pay_plan(pp.id, options)
    i.save_pay_plan.should be(true)

    i.reload

    ppsize = 2 + ( (tot - 60)/40 ).ceil
    i.pay_plans.size.should be(ppsize)

    ids = i.pay_plans.map(&:id)
    ids.shift
    i.destroy_pay_plans(ids).should be(true)
    i.reload
    i.pay_plans.sum(:amount).should == i.balance
    ids = i.pay_plans.map(&:id)

    i.destroy_pay_plans(ids).should be(true)
    i.pay_plans(true).size.should == 1
    i.reload
    i.pay_plans.sum(:amount).should == i.balance

  end

  scenario "Pay and then null transactions" do
    i = Income.new(income_params)
    i.save_trans.should == true

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    p = i.new_payment(:account_id => bank_account.id, :amount => i.balance,
                 :exchange_rate => 1, :currency_id => 1, :reference => 'Check INV-123')
    i.save_payment.should == true
    i.reload

    i.balance.should == 0
    i.should be_paid

    p.reload

    p.null_transaction.should be_true
    i.reload

    i.balance.should == i.total
    i.should_not be_paid
    i.should be_approved

    # bank creation and client deposits in another currency
    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0

    # Paying with another currency
    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :contact_id => client.id, :amount => 200, :reference => "Other currency check")

    client.reload

    al.save.should == true
    client.accounts.should have(2).elements
    al.conciliate_account.should == true
    
    bal = i.balance
    p = i.new_payment(:account_id => al.to_id, :amount => i.balance/2,
                 :exchange_rate => 2, :reference => 'Contact account')
    i.save_payment.should == true
    i.reload

    i.should be_paid
    i.balance.should == 0

    p.reload
    p.null_transaction.should be_true

    i.reload
    i.should_not be_paid

    client.reload
    client.account_cur(2).amount.should == -200
  end
end
