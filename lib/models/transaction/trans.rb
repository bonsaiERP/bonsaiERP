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
      set_defaults

      if draft?
        def self.draft_trans?; true; end
      else
        def self.approved_trans?; true; end
      end

      self.modified_by = UserSession.user_id
      # Set details
      details = TransactionDetails.new(self)
      details.set_details

      # Edit transaction if necessary
      edit_trans = Models::Transaction::Edit.new(self)

      return false if details.has_errors?

      edit_trans.save
    end


    private
    
    def check_repated_items
      h = Hash.new(0)
      transaction_details.each do |det|
        h[det.item_id] += 1
      end

      self.errors[:base] << I18n.t("errors.messages.repeated_items") if h.values.find {|v| v > 1 }
    end

  end

end
