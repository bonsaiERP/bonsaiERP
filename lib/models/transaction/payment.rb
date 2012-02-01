# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction::Payment

  extend ActiveSupport::Concern
  # includes
  include ActionView::Helpers::NumberHelper

  included do
    attr_reader :contact_payment, :current_ledger, :payment, :contact_account

    with_options :if => :payment? do |pay|
      pay.validate :valid_number_of_legers
    end
  end

  def payment?
    @payment === true
  end

  def new_payment(params = {})
    return false if draft? or paid? # Do not allow payments for draft? or paid? transactions

    params = set_payment_amount(params)
    # Find the right account
    params.delete(:to_id)
    params[:amount] = params[:base_amount].to_f + params[:interests_penalties].to_f

    @current_ledger = account_ledgers.build(params) {|al| al.operation = get_account_ledger_operation }
    @current_ledger.set_payment(true)
    @current_ledger.project_id = self.project_id
    @payment = true # To activate callbacks and validations

    @current_ledger
  end

  def new_devolution(params = {})
    return false if draft? # Do not allow devolution for draft? transactions

    # Find the right account
    params.delete(:to_id)
    params[:amount] = params[:base_amount].to_f + params[:interests_penalties].to_f

    @current_ledger = account_ledgers.build(params) {|al| al.operation = get_account_ledger_operation(true) }
    @current_ledger.set_payment(true)
    @current_ledger.project_id = self.project_id
    @payment = true # To activate callbacks and validations
    contact.get_contact_account(currency_id)

    @current_ledger
  end

  # ledger should
  # - Set to_id
  # - Set currency_id
  # - Set exchange_rate if the account and to have the same currency
  # - Update the account and to
  def save_payment
    return false unless payment?

    set_current_ledger_data
    
    return false unless valid_ledger_amount?

    mark_paid_pay_plans if credit? # anulate pay_plans if credit

    set_account_ledger_extras

    return false unless valid_contact_amount?
    #return false#
    res = true
    self.class.transaction do
      res = @current_ledger.save
      self.balance = balance - @current_ledger.amount_currency.abs
      self.balance = 0 if self.balance < 0
      self.state = 'paid' if balance.round(2) <= 0

      res = res && self.save
      raise ActiveRecord::Rollback unless res
    end

    res
  end

  def save_devolution
    return false unless payment?
    return false unless valid_verified_ledgers?

    set_current_ledger_data

    res = true
    return false unless valid_devolution_amount?

    self.class.transaction do
      res = @current_ledger.save
      self.balance += @current_ledger.amount_currency.abs
      self.state = 'approved'

      create_payment_pay_plan(pay_plans.last, @current_ledger.amount_currency.abs) if credit?
      res = res && self.save
      raise ActiveRecord::Rollback unless res
    end

    res
  end

  private

  def valid_devolution_amount?
    if @current_ledger.amount_currency.abs > total_paid.abs.round(2)
      @current_ledger.errors[:base_amount] << I18n.t("errors.messages.payment.devolution_amount")
      return false
    end
    true
  end

  def valid_contact_amount?
    @current_ledger.valid_contact_amount
    if @current_ledger.errors.any?
      @current_ledger.errors[:base_amount] = @current_ledger.errors[:base].join(", ")
      false
    else
      true
    end
  end

  def valid_verified_ledgers?
    if account_ledgers.pendent.any?
      @current_ledger.errors[:base] << I18n.t("errors.messages.payment.devolution_pendent_ledgers")
      return false
    end
    
    true
  end

  # Checks the amount of a ledger but with the transaction
  def valid_ledger_amount?
    val = ( balance - @current_ledger.amount_currency.abs )
  
    if val < -0.1
      @current_ledger.errors[:base_amount] << I18n.t("errors.messages.payment.greater_amount")
      return false
    end

    true
  end

  def set_current_ledger_data
    set_current_ledger_inverse

    set_account_ledger_description
    @current_ledger.contact_id = contact_id
    @current_ledger.conciliation = false

    @current_ledger.currency_id = @current_ledger.account_currency_id
  end

  def set_current_ledger_inverse
    if self.currency_id != OrganisationSession.currency_id and @current_ledger.account_currency_id == OrganisationSession.currency_id
      @current_ledger.inverse = true
    end
  end

  def get_account_ledger_operation(devolution = false)
    ret = ""
    case self.class.to_s
    when "Income"         then ret = "in"
    when "Expense", "Buy" then ret = "out"
    end

    ret = ret == "in" ? "out" : "in" if devolution
    ret
  end

  def valid_number_of_legers
    errors[:base] << "Error" if account_ledgers.select {|al| not al.persisted? }.size > 1
  end

  # marks the credit pay_plans that have been paid
  def mark_paid_pay_plans
    amt = @current_ledger.amount_currency
    current_pp = false

    pps = sort_pay_plans
    @current_ledger.payment_date = pps.first.payment_date

    pps.each do |pp|
      amt -= pp.amount
      pp.paid = true
      if amt <= 0
        current_pp = pp
        break 
      end
    end

    # Update payment_date for Transaction
    if amt === 0
      begin
        ind = pps.index(current_pp)
        self.payment_date = pps[ind + 1].payment_date
      rescue
        self.payment_date = current_pp.payment_date
      end
    else
      self.payment_date = current_pp.payment_date
    end

    create_payment_pay_plan(current_pp, amt) if current_pp and amt < 0
  end

  # Creates a pay_plan for the latest
  def create_payment_pay_plan(pp, amt)
    pay_plans.build(
      :payment_date => pp.payment_date, 
      :alert_date => pp.alert_date, 
      :amount => amt.abs,
      :email => pp.email,
      :currency_id => currency_id
    )
  end

  def set_payment_amount(params = {})
    if credit?
      pp = pay_plans.unpaid.first
      params[:base_amount] ||= pp.amount
      params[:interests_penalties] = params[:interests_penalties] || 0
    else
      params[:base_amount] ||= balance
    end
    
    params
  end

  def set_account_ledger_exchange_rate
    ac = @current_ledger.account

    if ac and ac.currency_id === currency_id and not(Contact::TYPES.include?(ac.original_type) )
      @current_ledger.exchange_rate = 1
    end
  end

  def set_account_ledger_extras
    set_account_ledger_description
    set_account_ledger_staff
  end

  def set_account_ledger_staff
    begin
      if @current_ledger.account.original_type === 'Staff'
        @current_ledger.staff_id = @current_ledger.account.accountable_id
      end
    rescue
    end
  end

  def set_account_ledger_description
    i18ntrans = I18n.t("transaction.#{self.class}")

    case
    when(@current_ledger.in? and self.is_a?(Income))
      txt = I18n.t("account_ledger.payment_description", 
        :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
        :ref => "#{self.ref_number}", :account => @current_ledger.account_name
      )
    when(@current_ledger.out? and self.is_a?(Buy))
      txt = I18n.t("account_ledger.payment_description", 
        :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
        :ref => "#{self.ref_number}", :account => @current_ledger.account_name
      )
    else
      txt = I18n.t("account_ledger.devolution_description",
                  :trans => self.to_s, :account => @current_ledger.account_name)
    end

    # Add currency text if necessary
    unless currency_id === @current_ledger.account_currency_id
      arr = [@current_ledger.currency_symbol, currency_symbol]
      cur1, cur2 = @current_ledger.inverse? ? arr.reverse : arr

      txt << " " << I18n.t("currency.exchange_rate",
        :cur1 => "#{ cur1 } 1",
        :cur2 => "#{ cur2 } #{number_to_currency @current_ledger.exchange_rate, :precision => 4}"
      )
    end

    @current_ledger.description = txt
  end

end
