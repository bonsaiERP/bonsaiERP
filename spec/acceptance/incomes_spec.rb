# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require File.dirname(__FILE__) + '/acceptance_helper'

#expect { t2.save }.to raise_error(ActiveRecord::StaleObjectError)

feature "Income", "test features" do
  background do
    #create_organisation_session
    OrganisationSession.set(:id => 1, :name => 'ecuanime', :currency_id => 1)
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

  # Not repeated items
  # Not included items
  scenario "Should not alow errors" do
    data = income_params.dup
    data[:transaction_details_attributes] << { "description"=>"jejeje", "item_id"=>1, "price"=>3, "quantity"=> 2}
 
    # Repeated items
    i = Income.new(data)
    i.save_trans.should be_false
    i.errors[:base].should == [ I18n.t("errors.messages.transaction.repeated_items") ]

    # not included items
    data[:transaction_details_attributes] = [{item_id: 1000, price: 3, quantity: 2}]
    i = Income.new(data)
    i.save_trans.should be_false
    i.transaction_details[0].errors[:item_id].should_not be_empty
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
    i.transaction_details[0].ctype.should == "Income"
    i.transaction_details[1].balance.should == 20
    i.transaction_details[1].original_price.should == 5

    i.approve!.should == true

    i = Income.find(i.id)
    i.approver_id.should == 1
    i.should be_approved
    i.should_not be_draft_trans

    # Create a payment
    i.payment?.should == false

    p = i.new_payment(:account_id => bank_account.id, :base_amount => 30, :exchange_rate => 1, :reference => 'Cheque 143234', :operation => 'out')
    p.class.should == AccountLedger
    p.payment?.should == true
    p.operation.should == 'in'
    p.amount.should == 30
    p.interests_penalties.should == 0

    i.payment?.should == true

    bal = i.balance

    i.save_payment.should == true
    p.reload
    #p.to_id.should == Account.org.find_by_original_type(i.class.to_s).id
    p.description.should_not == blank?
    p.amount.should == 30
    p.should be_persisted
    p.should_not be_inverse

    i.balance.should == bal - 30
    p.persisted?.should be_true

    p.account.original_type.should == "Bank"
    #p.to.original_type.should == "Income"

    p.account.amount.should == 0
    #p.to.amount.should == 0

    p.conciliate_account.should be_true
    p.reload

    p.approver_id.should == UserSession.user_id
    p.approver_datetime.kind_of?(Time).should == true

    p.account.amount.should == 30
    #p.to.amount.should == - 30

    i.deliver.should == false
    
    p = i.new_payment(:account_id => bank_account.id, :base_amount => i.balance, :reference => 'Cheque 222289', :exchange_rate => 1)

    i.save_payment.should == true

    p.conciliation.should == false
    i.should be_paid
    i.reload
    p.reload

    # Conciliation
    p.conciliate_account.should be_true
    #p.reload

    p.conciliation.should be_true
    p.account.amount.should == i.total
    #p.to.amount.should == -i.total

    i.reload
    i.balance.should == 0
    i.should be_deliver

  end

  scenario "Create a an income with credit" do
    i = Income.new(income_params)
    i.save_trans.should == true

    # Prevent from having draft_trans? to true
    i = Income.find(i.id)
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
    p.base_amount.should == 30

    i.save_payment.should == true
    p.should be_persisted
    i.reload
    
    i.pay_plans.unpaid.size.should == (i.total/30).ceil - 1
    i.balance.should == i.total - 30
    i.payment_date.should.should == i.pay_plans.unpaid.first.payment_date

    p.reload
    p.amount.should == 30
    p.account.amount.should == 0
    #p.to.amount.should == 0

    p.conciliate_account.should == true

    # approve deliver for the income
    i.approve_deliver.should be_true
    i.deliver_approver_id.should == UserSession.user_id
    i.deliver_datetime.class.should == ActiveSupport::TimeWithZone
    i.should be_deliver

    p.reload
    p.should be_conciliation
    
    p.account.amount.should == 30
    #p.to.amount.should == -30

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
    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :base_amount => 45)
    
    i.save_payment.should == true
    p.conciliate_account.should == true
    i.reload

    i.pay_plans.unpaid.size.should == size - 1
    i.balance.should == bal - 45

    p.reload
    p.account.amount.should == 30 + 45
    #p.to.amount.should == -(30 + 45)

    p = i.new_payment(:account_id => bank_account.id, :exchange_rate => 1, :reference => 'Cheque 143234', :base_amount => i.balance)
    
    i.save_payment.should == true

    i.reload
    i.pay_plans.unpaid.size.should == 0
    i.balance.should == 0
    p.conciliate_account.should == true

    p.reload

    p.account.amount.should == i.total
    #p.to.amount.should == -i.total
    
  end

  scenario "Create credit with interests" do
    i = Income.new(income_params)
    i.save_trans.should == true
    i = Income.find(i.id)

    i.approve!.should == true

    # Approve credit
    i.approve_credit(:credit_reference => "Ref 23728372", :credit_description => "Yeah").should == true
    i.pay_plans.unpaid.size.should == 1
    i.pay_plans.first.amount.should == i.balance

    d = Date.today

    pp = i.new_pay_plan(:payment_date => d, :alert_date => d - 5.days, :amount => 30, :repeat => "1")

    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).ceil
    
    tot_pps = i.pay_plans.inject(0) {|s,pp| s += pp.amount unless pp.paid?; s }
    tot_pps.should == i.balance

    # edit pay_plan
    pp = i.pay_plans[1]
    pp_last = i.pay_plans.last
    amt = pp_last.amount + pp.amount
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date, :amount => amt)
    i.save_pay_plan.should == true
    i.reload

    i.pay_plans.unpaid.size.should == (i.balance/30).floor
    i.pay_plans[1].id.should == pp.id
    i.pay_plans[1].amount.should == amt
    
    # edit second pay_plan and repeat pattern
    pp = i.pay_plans[1]
    
    i.edit_pay_plan(pp.id, :payment_date => pp.payment_date, :alert_date => pp.alert_date,
                    :amount => 60, :repeat => true)
    i.save_pay_plan.should == true
    i.reload
    i.pay_plans.size.should == ( (i.balance - 30)/60 ).ceil + 1

  end

  scenario "Make payment with a contact account" do
    i = Income.new(income_params)
    i.save_trans.should == true
    i = Income.find(i.id)

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
    i = Income.find(i.id)
  
    i.approve!.should == true

    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0

    p = i.new_payment(:account_id => new_bank_account.id, :base_amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should be(true)
    i.reload
    i.account_ledgers.first.amount.should == 30
    i.balance.should == i.total - 2 * 30
    p.reload

    p.account.amount.should == 0
    #p.to.amount.should == 0

    p.conciliate_account.should be(true)
    p.reload

    p.account.amount.should == 30
    p.account_original_type.should == "Bank"
    #p.to.amount.should == -2 * 30

    p = i.new_payment(:account_id => new_bank_account.id, :base_amount => 30, :interests_penalties => 1,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')


    p.amount.should == 31
    p.base_amount.should == 30
    p.interests_penalties.should == 1

    i.save_payment.should be(true)

    p.should be_persisted
    p.reload

    p.interests_penalties.should == 1
    p.base_amount.should == 30
    p.amount.should == 31
    p.conciliate_account.should be(true)

    i.reload
    i.account_ledgers.first.amount.should == 31
    i.account_ledgers.first.amount_currency.should == 60
    i.balance.should == i.total - 2 * 60

    p.reload
    p.account.amount.should == 61
    #p.to.amount.should == -(30 + 31) * 2

    log.info "Pay with contact account and with interests penalties"

    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :contact_id => client.id, :amount => 100, :reference => "Other currency check")
    al.save.should be(true)
    al.conciliate_account.should be(true)
    al.reload
    
    al.to.amount.should == -100
    i.reload

    bal = i.balance
    p = i.new_payment(:account_id => al.to_id, :base_amount => i.balance/2, :interests_penalties => 1,
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
    i = Income.find(i.id)

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

    # Pay with other currency
    p = i.new_payment(:account_id => al.to_id, :base_amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should be_true
    p.should be_persisted

    i.reload
    i.pay_plans.unpaid.sum(:amount).should == i.balance

    income_account = Account.find_by_original_type("Income")
    
    log.info("Set the correct description for a payment with other currency")
    c1 = Currency.find(i.currency_id)
    c2 = Currency.find(p.currency_id)

    i18ntrans = I18n.t("transaction.#{i.class}")
    txt = I18n.t("account_ledger.payment_description", 
      :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
      :ref => "#{i.ref_number}", :account => p.account_name
    )
    txt << " " << I18n.t("currency.exchange_rate",
      :cur1 => "#{p.currency_symbol} 1" , 
      :cur2 => "#{c1.symbol} 2,0000"
    )

    p.description.should == txt
    p.should_not be_conciliation

    i.balance.should == i.total - 30 * 2

    p.conciliate_account.should be_true
    p.reload
    client.reload

    client.account_cur(2).amount.should == -200 + 30
    #income_account.cur(2).amount.should == -30

    i.pay_plans.unpaid.size.should == ( (i.balance)/30 ).ceil
    i.pay_plans.paid.size.should == 2
    # Remember payment with other currency
    i.pay_plans_balance.should == i.total - 60

    #i.pay_plans.unpaid

    # Check how the payment date moved after paying
    p = i.new_payment(:account_id => al.to_id, :base_amount => 20,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')
    
    # Should move to the last payed date
    pdate = i.pay_plans.unpaid[1].payment_date

    i.save_payment.should be_true
    p.should be_persisted

    i.reload
    # 20 * 2
    pp = i.pay_plans.unpaid.first
    pp.amount.should == 20
    pp.payment_date.should == pdate
  end

  scenario "check different updates and modifications to pay_plans" do
    i = Income.new(income_params)
    i.save_trans.should == true
    i = Income.find(i.id)

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
    i = Income.find(i.id)

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should == true

    p = i.new_payment(:account_id => bank_account.id, :base_amount => i.balance,
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
    p = i.new_payment(:account_id => al.to_id, :base_amount => i.balance/2,
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


  scenario "Make payment with a contact account and validate contact amount" do
    i = Income.new(income_params)
    i.save_trans.should == true
    i = Income.find(i.id)

    tot = ( 3 * 10 + 5 * 20 ) * 0.97
    i.total.should == tot.round(2)
    i.balance.should == i.total

    i.approve!.should be_true

    # Make a deposit
    al = AccountLedger.new_money(:operation => "in", :account_id => bank_account.id, :contact_id => client.id, :amount => 50, :reference => "Check 1120012" )
    al.save.should be_true
    al.conciliate_account.should be_true

    client.account_cur(1).amount.should == -50

    i.reload
    p = i.new_payment(:account_id => client.account_cur(1).id, :reference => 'Test for client', :exchange_rate => 1)

    p.base_amount.should == i.balance

    i.save_payment.should be_false

    p.errors[:amount].should_not be_empty
    p.errors[:base_amount].should_not be_empty

    i.reload
    p = i.new_payment(:account_id => client.account_cur(1).id, :reference => 'Test for client', :exchange_rate => 1, :base_amount => 50)
    i.save_payment.should be_true

    al = AccountLedger.new_money(:operation => "out", :account_id => bank_account.id, :contact_id => client.id, :amount => 10, :reference => "Critic")

    al.save.should be_true
    al.conciliate_account.should be_true
    al.should be_persisted
    al.currency_id.should == 1
    al.to_id.should == client.account_cur(1).id

    p.reload

    client.reload
    client.account_cur(1).amount.should == -40

    p.conciliate_account.should be_false
    p.errors[:amount].should_not be_blank
    p.errors[:base].should_not be_blank
  end

  scenario "Pay with a differen curency" do
    i = Income.new(income_params.merge(:discount => 0))
    i.save_trans.should == true
    i = Income.find(i.id)
  
    i.approve!.should == true

    new_bank = create_bank(:currency_id => 2)
    new_bank_account = new_bank.account
    new_bank_account.amount.should == 0

    p = i.new_payment(:account_id => new_bank_account.id, :base_amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should be(true)
    i.reload
    i.account_ledgers.first.amount.should == 30
    i.balance.should == i.total - 2 * 30
    p.reload

    p.account.amount.should == 0
    #p.to.amount.should == 0

    p.conciliate_account.should be(true)
    p.reload

    p.account.amount.should == 30
    p.account_original_type.should == "Bank"
    #p.to.amount.should == -2 * 30

    p = i.new_payment(:account_id => new_bank_account.id, :base_amount => 30, :interests_penalties => 1,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    p.amount.should == 31
    p.interests_penalties.should == 1
    i.save_payment.should be(true)
    p.conciliate_account.should be(true)

    i.reload
    i.account_ledgers.first.amount.should == 31
    i.account_ledgers.first.amount_currency.should == 60
    i.balance.should == i.total - 2 * 60

    p.reload
    p.account.amount.should == 61
    #p.to.amount.should == -(30 + 31) * 2

    log.info "Pay with contact account and with interests penalties"

    al = AccountLedger.new_money(:operation => 'in', :account_id => new_bank_account.id, :contact_id => client.id, :amount => 100, :reference => "Other currency check")
    al.save.should be(true)
    al.conciliate_account.should be(true)
    al.reload
    
    al.to.amount.should == -100
    i.reload

    bal = i.balance
    p = i.new_payment(:account_id => al.to_id, :base_amount => i.balance/2, :interests_penalties => 1,
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
    i = Income.find(i.id)

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

    # Pay with different currency and from a contact account
    p = i.new_payment(:account_id => al.to_id, :base_amount => 30,
                 :exchange_rate => 2, :currency_id => 2, :reference => 'Last check')

    i.save_payment.should == true
    p.should be_persisted

    income_account = Account.find_by_original_type("Income")
    
    log.info("Set the correct description for a payment with other currency")
    c1 = Currency.find(i.currency_id)
    c2 = Currency.find(p.currency_id)

    i18ntrans = I18n.t("transaction.#{i.class}")
    txt = I18n.t("account_ledger.payment_description", 
      :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
      :ref => "#{i.ref_number}", :account => p.account_name
    )
    txt << " " << I18n.t("currency.exchange_rate",
      :cur1 => "#{ p.currency_symbol } 1" , 
      :cur2 => "#{c1.symbol} 2,0000"
    )

    p.description.should == txt
    p.should_not be_conciliation

    i.balance.should == i.total - 30 * 2

    p.conciliate_account.should be_true
    p.reload
    client.reload

    client.account_cur(2).amount.should == -200 + 30

    i.reload
    i.pay_plans.unpaid.size.should == ( (i.total - 60)/30 ).ceil
    i.pay_plans.paid.size.should == 2
    i.pay_plans_balance.should == i.total - 60

    i.balance.should == i.pay_plans.unpaid.sum(:amount)
  end

  scenario "Test creation and payment of interests penalties with different currencies" do

    i_params = income_params.dup
    i_params[:discount] = 0
    i_params[:transaction_details_attributes][0][:price] = 100
    i_params[:transaction_details_attributes][0][:quantity] = 10
    i_params[:transaction_details_attributes][1][:price] = 100
    i_params[:transaction_details_attributes][1][:quantity] = 10
    #(100 * 10 + 100 * 10)
    i = Income.new(i_params)

    i.should be_cash
    i.save_trans.should be_true
    i.should be_draft
    i.deliver.should be_false
    i.delivered.should be_false
    i.total.should == 2000
    i.pay_plans.should have(0).elements

    i = Income.find(i.id)

    i.approve!.should be_true
    i.approve_credit(:credit_reference => "Ref 123", :credit_description => "Yeah!!").should be_true

    i.reload
    i.pay_plans.should have(1).element
    p = i.pay_plans.first
    p.amount.should == i.balance
    
    i.edit_pay_plan(p.id, :amount => 200, :interests_penalties => 200, :repeat => true)

    i.save_pay_plan.should be_true
    i.reload
    i.pay_plans.should have(10).elements

    #i.pay_plans[0].interests_penalties.should == 200
    i.pay_plans.map(&:amount).uniq.should == [200]

    # create bank
    new_bank = create_bank(:currency_id => 2)
    new_bank.should be_persisted

    p = i.new_payment
    p.amount.should == 200
  end

  scenario "Check amount change of prices" do
    items = Item.find(1, 2)

    i_params = income_params.dup

    i1 = items.first
    i2 = items.last

    # no changes
    i_params[:discount] = 0
    i_params[:transaction_details_attributes] = [
      {:item_id => i1.id, :quantity => 10, :price => i1.price },
      {:item_id => i2.id, :quantity => 20, :price => i2.price }
    ]
    tot = i1.price * 10 + i2.price * 20

    i = Income.new(i_params)
    i.save_trans.should be_true
    #puts i.transaction_details.map(&:original_price)
    i = Income.find(i.id)

    i.should be_persisted
    i.should be_draft
    i.total.should == tot
    i.original_total.should == i1.price * 10 + i2.price * 20
    #puts i.send(:calculate_orinal_total)
    i.should_not be_discounted

    # item prices
    i_params[:transaction_details_attributes] = [
      {:item_id => i1.id, :quantity => 10, :price => i1.price + 1 },
      {:item_id => i2.id, :quantity => 20, :price => i2.price }
    ]

    # Only change of price
    i = Income.new(i_params)
    i.save_trans.should be_true
    i = Income.find(i.id)

    tot = (i1.price + 1) * 10 + i2.price * 20

    i.should be_persisted
    i.should be_draft
    i.total.should == tot
    i.original_total.should == i1.price * 10 + i2.price * 20
    i.should be_discounted

    # With discount
    i_params[:discount] = 3
    i = Income.new(i_params)
    i.save_trans.should be_true
    i = Income.find(i.id)

    i.original_total.should == i1.price * 10 + i2.price * 20
    i.should be_discounted

    # with taxes
    i_params[:discount] = 3
    tax = Tax.first
    i_params[:taxis_ids] = [tax.id]
    i = Income.new(i_params)
    i.save_trans.should be_true
    i.original_total.should == ( i1.price * 10 + i2.price * 20 ) * (1 + tax.rate/100)
    i.should be_discounted

    # with different currency
    # no changes
    i_params = income_params.dup
    i_params[:discount] = 0
    i_params[:currency_id] = 2
    i_params[:exchange_rate] = 1.5
    i_params[:transaction_details_attributes] = [
      {:item_id => i1.id, :quantity => 10, :price => i1.price/1.5 },
      {:item_id => i2.id, :quantity => 20, :price => i2.price/1.5 }
    ]

    i = Income.new(i_params)
    i.save_trans.should == true

    i.should be_persisted
    i.discount.should == 0

    otot = (i1.price/1.5).round(2) * 10 + ( i2.price/1.5 ).round(2) * 20
    otot = BigDecimal.new(otot.to_s)

    i.reload
    i.total.should == otot
    i.original_total.should == otot
    i.total.should == i.original_total
    i.should_not be_changed
  end

  scenario "Make a income in other currency and pay with organisation currency" do
    data = income_params.dup.merge(exchange_rate: 2, currency_id: 2, discount: 0)
    data[:transaction_details_attributes][0][:price] = 1.5
    data[:transaction_details_attributes][1][:price] = 2.5

    i = Income.new(data)
    i.save_trans.should be_true
    i.should be_persisted
    i.total.should == (1.5 * 10 + 2.5 * 20)

    i.approve!.should be_true

    p = i.new_payment(:account_id => bank_account.id, :base_amount => 30, :exchange_rate => 2, :reference => 'Cheque 143234', :operation => 'in')
    i.save_payment.should == true
    p.should be_persisted
    p.should be_inverse
    p.amount.should == 30
    p.amount_currency.should == 15

    i.balance.should == i.total - 15

  end
end
