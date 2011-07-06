# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction
  module Trans
    extend ActiveSupport::Concern

    included do
      before_create :set_creator
    end

    module InstanceMethods
      # Principal method to store when saving a new trans or editing details
      def save_trans
        set_details_type
        calculate_total_and_set_balance
        set_balance_inventory
      end

      private
        def set_creator
          self.creator_id = UserSession.user_id
        end

        # Sets the type of the class making the transaction
        def set_details_type
          self.transaction_details.each{ |v| v.ctype = self.class.to_s }
        end

        # Calculates the total value and stores it
        def calculate_total_and_set_balance
          #self.gross_total = transaction_details.select{|t| !t.marked_for_destruction? }.inject(0) {|sum, det| sum += det.total }
          self.gross_total = transaction_details.inject(0) {|s,det| s += det.total unless det.marked_for_destruction?; s}
          self.total = gross_total - total_discount + total_taxes
          self.balance = total / currency_exchange_rate if total > 0
        end

        def set_balance_inventory
          self.balance_inventory = total
        end
    end

  end
end
