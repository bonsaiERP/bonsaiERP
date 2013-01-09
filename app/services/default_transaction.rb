# encoding: utf-8
class DefaultTransaction < BaseService
  attr_reader :transaction

  def initialize(trans)
    raise 'The parameter must be a Transaction class' unless trans.is_a?(Transaction)
    @transaction = trans
  end

  def create
  end

  def update(params)
  end

private
  # Sets a default payment date using PayPlan
  def update_payment_date
  end

  def set_details_balance
    transaction_details.each {|det| det.balance = det.quantity }
  end

  def set_transaction_data
    set_details_original_prices
    transaction.gross_total = original_transaction_total
    transaction.balance = transaction.total
  end

  def set_details_original_prices
    transaction_details.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def original_transaction_total
    transaction_details.inject(0) do |sum, det|
      sum += det.quantity * det.original_price
    end
  end

  def item_prices
    @item_prices ||= Hash[Item.where(id: item_ids).values_of(:id, :price)]
  end

  def item_ids
    transaction_details.map(&:item_id)
  end

  def transaction_details
    transaction.transaction_details
  end
end
