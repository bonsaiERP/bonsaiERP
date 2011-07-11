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

      @current_ledger = account_ledgers.build({:operation => 'in', :to_id => account_id
      }.merge(params))

      @current_ledger.set_payment(true)
      
      def self.payment?; true; end # To activate callbacks and validations
      @current_ledger
    end

    def save_payment
      return false unless payment?

      null_pay_plans unless cash? # anulate all payments if credit
      self.balance = balance - @current_ledger.amount
      self.state = 'paid' if balance <= 0

      self.save
    end

    private
      def valid_number_of_legers
        errors[:base] << "Error" if account_ledgers.select {|al| not al.persisted? }.size > 1
      end

      def null_pay_plans

      end
    
  end
end
