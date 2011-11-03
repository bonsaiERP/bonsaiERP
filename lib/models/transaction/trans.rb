# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
  module Trans
    
    extend ActiveSupport::Concern

    [:draft_trans?, :approved_trans?].each do |met|
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{met}
          false
        end
      CODE
    end

    # validations callbacks
    included do

      with_options :if => :draft_trans? do |trans|
        # Validations
        trans.validate :check_repated_items
        #trans.before_save :set_transaction_totals
      end

      with_options :if => :approved_trans? do |trans|

      end

    end

    def save_trans
      self.state ||= "draft"

      if draft?
        def self.draft_trans?; true; end
      else
        def self.approved_trans?; true; end
      end

      self.modified_by = UserSession.user_id
      # Set details
      details = TransactionDetails.new(self)
      details.set_details

      # Set totals
      set_transaction_totals

      # Edit transaction if necessary
      edit_trans = Models::Transaction::Edit.new(self)
      edit_trans.update

      return false if details.has_errors?

      edit_trans.save
    end


    module InstanceMethods

    private
      
      def set_transaction_totals
        calculate_total_and_set_balance
        calculate_orinal_total
      end

      def calculate_orinal_total
        s = transaction_details.inject(0) do |s, det|
          s += ( det.original_price.to_f/exchange_rate ).round(2) * det.quantity unless det.marked_for_destruction?
          s
        end

        t_taxes = tax_percent/100 * s
        s += t_taxes
        self.discounted = (s == total ? false : true)

        self.original_total = s
      end

      # Calculates the real total value and stores it
      def calculate_total_and_set_balance
        self.tax_percent = taxes.inject(0) {|s, imp| s += imp.rate }
        self.gross_total = transaction_details.inject(0) {|s,det| s += det.total unless det.marked_for_destruction?; s}
        self.total = gross_total - total_discount + total_taxes
        self.balance = total if total > 0
      end

      def check_repated_items
        h = Hash.new(0)
        transaction_details.each do |det|
          h[det.item_id] += 1
        end

        self.errors[:base] << I18n.t("errors.messages.repeated_items") if h.values.find {|v| v > 1 }
      end

    end

  end
end
