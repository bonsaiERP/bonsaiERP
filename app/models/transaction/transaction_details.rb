# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Transaction::TransactionDetails
  extend ActiveSupport::Concern

  included do
    ########################################
    # Relationships
    has_many :transaction_details , dependent: :destroy, order: :id, foreign_key: :transaction_id, inverse_of: :transaction
    accepts_nested_attributes_for :transaction_details, allow_destroy: true
    ########################################
    # Validations
    validate :valid_number_of_items
    validate :valid_not_repeated_items
  end

  private
  # To have at least one item
  def valid_number_of_items
    self.errors[:base] << I18n.t('errors.messages.transaction.number_of_items') if transaction_details.empty?
  end

  def check_repeated_items
    h = Hash.new(0)
    transaction_details.each do |det|
      h[det.item_id] += 1

      if h[det.item_id] > 1
        transaction_details.errors[:item_id] << I18n.t('errors.messages.repeated_item')
      end
    end

    self.errors[:base] << I18n.t("errors.messages.repeated_items") if h.values.find {|v| v > 1 }
  end
end
