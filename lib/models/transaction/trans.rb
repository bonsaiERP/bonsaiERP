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

      with_options  :if => :draft_trans? do |trans|
        trans.before_save :save_trans_details
        trans.before_save :calculate_orinal_total
      end

      with_options :if => :approved_trans? do |trans|

      end

    end

    def save_trans
      self.state ||= "draft"

      if draft?
        def self.draft_trans?; true; end
        self.extend(ExtraMethods)
      else
        def self.approved_trans?; true; end
      end

      self.save
    end

    module ExtraMethods

    private

      def save_trans_details
        round_details
        set_details_type
        set_balance_inventory
        check_repated_items

        calculate_total_and_set_balance

        return false unless errors.empty?
      end

      def round_details
        transaction_details.each do |tdet|
          tdet.price = tdet.price.round(2)
        end
      end

      def calculate_orinal_total
        items = Item.org.where(:id => transaction_details.map(&:item_id)).values_of(:id, :price)

        s = transaction_details.inject(0) do |s, det|
          it = items.find {|i| i[0] === det.item_id }
          s += ( it[1].to_f/exchange_rate ).round(2) * det.quantity unless det.marked_for_destruction?
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

      # Calculates the real total value and stores it
      def calculate_total_and_set_balance
        self.tax_percent = taxes.inject(0) {|s, imp| s += imp.rate }
        self.gross_total = transaction_details.inject(0) {|s,det| s += det.total unless det.marked_for_destruction?; s}
        self.total = gross_total - total_discount + total_taxes
        self.balance = total if total > 0
      end

      def set_balance_inventory
        self.balance_inventory = total
      end

    end

  end
end
