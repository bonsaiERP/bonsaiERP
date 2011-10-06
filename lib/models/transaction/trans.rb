# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'active_support/concern'

module Models::Transaction
  module Trans
    extend ActiveSupport::Concern

    included do
      before_save :save_trans_details, :if => :draft?
    end

    module InstanceMethods
      # Principal method to store when saving a new trans or editing details
      def save_trans
        self.state ||= "draft"
        return false unless draft? # return false if state == 'draft'

        self.save
      end

      private

      def save_trans_details
        set_details_type
        calculate_total_and_set_balance
        set_balance_inventory
        set_total_discount_amount
        check_repated_items
        calculate_orinal_total

        return false unless errors.empty?
      end

      def calculate_orinal_total
        items = Item.org.where(:id => transaction_details.map(&:item_id)).values_of(:id, :price)
        s = transaction_details.inject(0) do |s, det|
          it = items.find {|i| i[0] === det.item_id }
          s += it[1]/exchange_rate * det.quantity unless det.marked_for_destruction?
          s
        end

        t_taxes = tax_percent/100 * s
        s += t_taxes
        self.discounted = (s == total ? false : true)

        self.original_total = s
      end

      def check_repated_items
        h = Hash.new(0)
        transaction_details.each do |det|
          h[det.item_id] += 1
        end

        self.errors[:base] << I18n.t("errors.messages.repeated_items") if h.values.find {|v| v > 1 }
      end

      # Sets the type of the class making the transaction
      def set_details_type
        self.transaction_details.each{ |v| v.ctype = self.class.to_s }
      end

      # Calculates the total value and stores it
      def calculate_total_and_set_balance
        self.tax_percent = taxes.inject(0) {|s, imp| s += imp.rate }
        self.gross_total = transaction_details.inject(0) {|s,det| s += det.total unless det.marked_for_destruction?; s}
        self.total = gross_total - total_discount + total_taxes
        self.balance = total if total > 0
      end

      def set_balance_inventory
        self.balance_inventory = total
      end

      def set_total_discount_amount

      end

    end

  end
end
