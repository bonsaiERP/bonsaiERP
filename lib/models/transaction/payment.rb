# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction::Payment

  extend ActiveSupport::Concern
  # includes
  include ActionView::Helpers::NumberHelper

  included do
    attr_reader :contact_payment, :current_ledger
    validate :valid_number_of_legers, :if => :payment?
  end

  module InstanceMethods
    def payment?; false; end

    def contact_payment?
      @contact_payment === true
    end

    def set_contact_payment(val = true)
      @contact_payment = true
    end

    def new_payment(params = {})
      return false if draft? or paid? # Do not allow payments for draft? or paid? transactions

      params = set_payment_amount(params)
      # Find the right account
      params.delete(:to_id)

      @current_ledger = account_ledgers.build(params) {|al| al.operation = get_account_ledger_operation }

      @current_ledger.set_payment(true)
      
      def self.payment?; true; end # To activate callbacks and validations

      @current_ledger
    end

    def save_payment
      return false unless payment?
      return false unless valid_account_ledger? # Don't use valid_ledger? when set @current_ledger otherwise validations are run twice

      @current_ledger.to_id = ::Account.org.find_by_original_type(self.class.to_s).id
      @current_ledger.conciliation = get_conciliation_for_account
      @current_ledger.description = get_payment_description
      mark_paid_pay_plans if credit? # anulate pay_plans if credit

      self.balance = balance - @current_ledger.amount
      self.state = 'paid' if balance <= 0

      self.save
    end

    private
      def get_payment_description
        i18ntrans = I18n.t("transaction.#{self.class}")

        #Cobro de Venta V1212, cuenta Karina Luna
        txt = I18n.t("account_ledger.payment_description", 
          :pay_type => i18ntrans[:pay], :trans => i18ntrans[:class], 
          :ref => "#{self.ref_number}", :account => @current_ledger.account_name
        )

        # Add currency text if necessary
        #txt << " " << I18nt("currency.tipo_cambio",
        #  :cur1 => "#{self.currency_symbol} 1" , 
        #  :cur2 => "#{ @current_ledger.currency_symbol } #{@current_ledger.exchange_rate}"
        #) unless currency_id == @current_ledger.currency_id

        txt
      end

      def valid_account_ledger?
        if @current_ledger.amount > balance
          @current_ledger.errors[:amount] = I18n.t("errors.messages.payment.greater_amount")
          false
        else
          true
        end
      end

      def get_conciliation_for_account
        case @current_ledger.account.original_type
        when "Bank" then false
        when "Cash" then true
        when "Client", "Supplier", "Staff" then true
        end
      end

      def get_account_ledger_operation
        case self.class.to_s
        when "Income" then "in"
        when "Expense", "Buy" then "out"
        end
      end

      def valid_number_of_legers
        errors[:base] << "Error" if account_ledgers.select {|al| not al.persisted? }.size > 1
      end

      # marks the credit pay_plans that have been paid
      def mark_paid_pay_plans
        amt = @current_ledger.amount
        int = @current_ledger.interests_penalties
        current_pp = false

        sort_pay_plans.each do |pp|
          amt -= pp.amount
          pp.paid = true
          if amt <= 0
            current_pp = pp
            break 
          end
        end

        create_payment_pay_plan(current_pp, amt) if current_pp and amt < 0
      end

      # Creates a pay_plan for the latest
      def create_payment_pay_plan(pp, amt)
        pay_plans.build(
          :payment_date => pp.payment_date, 
          :alert_date => pp.alert_date, 
          :amount => amt.abs,
          :interests_penalties  => pp.interests_penalties,
          :email => pp.email,
          :currency_id => currency_id
        )
      end

      def set_payment_amount(params = {})
        if credit?
          pp = pay_plans.unpaid.first
          params[:amount] ||= pp.amount
          params[:interests_penalties] ||= pp.interests_penalties
        else
          params[:amount] ||= balance
        end
        
        params
      end
    
  end
end
