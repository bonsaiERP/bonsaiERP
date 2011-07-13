# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction::Payment

  extend ActiveSupport::Concern

  included do
    validate :valid_number_of_legers, :if => :payment?
  end

  module InstanceMethods
    def payment?; false; end

    # TODO obtain data from pay_plans if credit
    def new_payment(params = {})
      return false if draft? # Do not allow payments to draft? transactions

      params = set_payment_amount(params)
      @current_ledger = account_ledgers.build({:operation => 'in', :to_id => account_id
      }.merge(params))

      @current_ledger.set_payment(true)
      
      def self.payment?; true; end # To activate callbacks and validations
      @current_ledger
    end

    def save_payment
      return false unless payment?
      return false unless valid_ledger?

      null_pay_plans unless cash? # anulate all payments if credit

      self.balance = balance - @current_ledger.amount
      self.state = 'paid' if balance <= 0

      self.save
    end

    private
      def valid_ledger?
        ret = @current_ledger.valid?
        if @current_ledger.amount > balance
          @current_ledger.errors[:amount] = I18n.t("errors.messages.payment.greater_amount")
          ret = false
        end

        ret
      end

      def valid_number_of_legers
        errors[:base] << "Error" if account_ledgers.select {|al| not al.persisted? }.size > 1
      end

      def null_pay_plans
        amt = amount
        int = interests_penalties

        sort_pay_plans.each do |pp|
          amt -= pp.amount
          if amt <= 0
            current_pp = pp
            break 
          end
        end

        create_payment_pay_plan(current_pp, amt) if current_pp
      end

      # Creates a pay_plan for the latest
      def create_payment_pay_plan(pp, amt)
        pay_plans.build(
          :payment_date => pp.payment_date, 
          :alert_date => pp.alert_date, 
          :amount => amt.abs,
          :interests_penalties  => int,
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
