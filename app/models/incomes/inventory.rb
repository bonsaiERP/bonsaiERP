# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Incomes::Inventory < Inventories::Form
  attribute :income_id, Integer

  validates_presence_of :income

  delegate :income_details, to: :income

  class << self
    def new_in(attrs = {})
      inv = new(attrs)
      inv.inventory_operation.attributes = income_attributes(attrs.merge(operation: 'inc_in'))
      inv.inventory_operation.set_ref_number
      inv
    end

    def new_out(attrs = {})
      inv = new(attrs)
      inv.inventory_operation.attributes = income_attributes(attrs.merge(operation: 'inc_out'))
      inv.inventory_operation.set_ref_number
      inv
    end

  private
    def income_attributes(attrs = attrs)
      attrs.slice(:store_id, :date, :ref_number, :description, :operation)
      .merge(account_id: attrs.fetch(:income_id))
    end
  end

  def save
    if @inventory_operation.is_out?
      save_out
    else
      save_in
    end
  end

  def income
    @income ||= Income.find(income_id)
  end

private
  def save_out
    return false unless valid_out?
    res = true

    commit_or_rollback do
      res = inventory_operation.save

      res = res && update_stocks {|st| st.quantity - item_quantity(st.item_id)}

      update_items {|it, det| det.balance - it.quantity }

      res = res && income.save
    end

    set_errors(inventory_operation) unless res

    res
  end

  def save_in
    return false unless valid_in?
    res = true

    commit_or_rollback do
      res = inventory_operation.save

      res = res && update_stocks {|st| st.quantity + item_quantity(st.item_id)}

      update_items {|it, det| det.balance + it.quantity }

      res = res && income.save
    end

    set_errors(inventory_operation) unless res

    res
  end

  def valid_in?
    l = lambda {|it, inc_det| (it.quantity + inc_det.balance) > inc_det.quantity }
    valid_items_quantities?(l)  && valid?
  end

  def valid_out?
    l = lambda {|it, inc_det| it.quantity > inc_det.balance}
    valid_items_quantities?(l)  && valid?
  end

  def update_items(&b)
    items.each do |it|
      det = income_detail(it.item_id)
      det.balance = b.call(it, det)
    end
  end

  def valid_items_quantities?(b)
    valid = true

    items.each do |it|
      if b.call(it, income_detail(it.item_id))
        valid = false
        it.errors.add(:quantity, I18n.t('errors.messages.inventory_operation_detail.transaction_quantity'))
      end
    end

    valid
  end

  def income_detail(item_id)
    income_details.find {|det| det.item_id === item_id }
  end
end
