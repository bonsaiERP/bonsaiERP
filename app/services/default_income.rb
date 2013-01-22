# encoding: utf-8
class DefaultIncome < DefaultTransaction
  attr_reader :income

  delegate :state, :income_details, :discount, to: :income

  def initialize(inc)
    raise 'Must be a Income class' unless inc.is_a?(Income)
    @transaction = @income = inc
  end

  def create
    set_income_data

    income.save
  end

  def update(params)
    income.attributes = params

    income.save
  end

private
  def set_income_data
    set_new_details
    income.gross_total = original_income_total
    income.balance = income.total
    income.state = 'draft' if state.blank?
    income.discounted = true if discount > 0
    income.creator_id = UserSession.id
  end

  def set_new_details
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
      det.balance = det.quantity
    end
  end

  def set_details_balance
    income_details.each {|det| det.balance = det.quantity }
  end

  def set_details_original_prices
    income_details.each do |det|
      det.original_price = item_prices[det.item_id]
    end
  end

  def original_income_total
    income_details.inject(0) do |sum, det|
      sum += det.quantity.to_f * det.original_price.to_f
    end
  end

  def item_ids
    income_details.map(&:item_id)
  end
end
