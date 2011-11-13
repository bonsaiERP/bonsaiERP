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
      # Indicates if the details have any errors
      @errors              = false
    end

    def set_details
      transaction_details.each do |td|
        td.ctype          = self.class.to_s
        td.price          = td.price.round(2)
        td.quantity       = td.quantity.round(2)
        td.original_price = item_prices[td.item_id]
        # Validations
        valid_item(td)
      end
    end

    def item_prices
      @prices ||= Hash[Item.where(:id => item_ids).values_of(:id, :price)]
    end

    def item_ids
      transaction_details.map(&:item_id)
    end

    def has_errors?
      @errors
    end

  private
    def valid_item(td)
      @keys ||= item_prices.keys
      unless @keys.include?(td.item_id)
        td.errors[:item_id] << I18n.t("errors.messages.invalidkeys")
        @errors = true
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
