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
        #trans.validate :check_repeated_items
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

      if details.has_errors?
        self.errors[:"transaction_details.item_id"] << "error"
        return false 
      end

      edit_trans.save
    end

  end

end
