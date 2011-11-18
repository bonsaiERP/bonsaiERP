# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::Transaction
  # Class that saves all details of data
  class TransactionDetails
    attr_reader :transaction, :transaction_details, :errors

    def initialize(transaction)
      @transaction         = transaction
      @transaction_details = @transaction.transaction_details
    end

    def set_details
      transaction_details.each_with_index do |td, i|
        td.ctype          = transaction.class.to_s
        td.price          = td.price.round(2)
        td.quantity       = td.quantity.round(2)
        td.original_price = item_prices[td.item_id]
        # Validations
        valid_item(td, i)
      end
    end

    def item_prices
      @prices ||= Hash[Item.where(:id => item_ids).values_of(:id, :price)]
    end

    def item_ids
      transaction_details.map(&:item_id)
    end

    def has_errors?
      transaction_details.map{|v| v.errors.any? }.include?(true)
    end

    private

    def old_details
      @old_details ||= TransactionDetail.where(:transaction_id => transaction.id).order(:id)
    end

    def valid_item(td, index)
      @keys ||= item_prices.keys

      # Check change of item_id
      unless transaction.draft?
        o_td = old_details[index]
        if o_td.present? and td.delivered > 0 and td.item_id != o_td.item_id
          td.item_id = old_details[index].item_id
          td.errors[:item_id] << I18n.t("errors.messages.transaction_details.change_item")
        end
      end

      # Check if marked for destruction
      unless transaction.draft?
        if td.marked_for_destruction? and td.delivered > 0
          td.reload
          td.errors[:item_id] << I18n.t("errors.messages.transaction_details.destroy")
        end
      end

      unless @keys.include?(td.item_id)
        td.errors[:item_id] << I18n.t("errors.messages.invalidkeys")
      end

      if !transaction.draft? and td.quantity < td.delivered
        td.errors[:quantity] << I18n.t("errors.messages.transaction_details.delivered_quantity")
      end

    end
    
    def round_prices
      transaction_details.each {|td| td.price = td.price.round(2)}
    end

    def set_original_prices
      transaction_details.each do |td|
        td.original_price = item_prices[td.item_id]
      end
    end

  end
end
