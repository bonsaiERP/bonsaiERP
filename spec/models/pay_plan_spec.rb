require 'spec_helper'

describe PayPlan do
  before(:each) do
    OrganisationSession.set(:id => 1, :name => 'ecuanime')
    d = Date.today
    
    @params = { :alert_date => (d - 5.days), :payment_date => d,
     :amount => 100, :interests_penalties => 0,
     :ctype => 'Income', :description => 'Prueba de vida!', 
     :email => true, :transaction_id => 1}

    CurrencyRate.stubs(:current_hash => {2 => 7, 3 => 9})

    PayPlan.stubs(:get_currency_ids => [2, 3])
  end

  it 'should return error for each locale' do
    PayPlan.any_instance.stubs(:pay_type => 'cobro')
    pp = PayPlan.new(:amount => 0, :interests_penalties => 0, :currency_id => 1, 
        :payment_date => Date.today, :alert_date => Date.today + 2.days)

    pp.valid?.should == false
    pp.errors.messages[:amount].to_s.should =~ /#{I18n.t("errors.messages.pay_plan.valid_amount_and_interests")}/

    pp.errors.messages[:alert_date].to_s.should =~ /#{I18n.t("errors.messages.pay_plan.valid_date", :pay_type => 'cobro')}/
  end

  it 'should create the currency_query query' do
    PayPlan.create_currency_query(1, 30.days.from_now).should =~ /WHEN 2 THEN amount \* 7/
    PayPlan.create_currency_query(1, 30.days.from_now).should =~ /WHEN 3 THEN amount \* 9/
  end

  #it 'should create complete query' do
  #  puts PayPlan.get_most_important(1, 30.days.from_now)
  #end

end
