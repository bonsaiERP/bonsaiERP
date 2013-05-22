# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Movements::InventoryIn < Inventories::Form
  attribute :account_id, Integer

  attr_reader :movement

private
  #def save_out
  #  return false unless valid_out?
  #  res = true

  #  commit_or_rollback do
  #    res = inventory.save

  #    res = res && update_stocks {|st| st.quantity - item_quantity(st.item_id)}

  #    update_items {|it, det| det.balance - it.quantity }

  #    res = res && income.save
  #  end

  #  set_errors(inventory) unless res

  #  res
  #end

  def save_in
    return false unless valid_in?
    res = true

    commit_or_rollback do
      res = inventory.save

      res = res && update_stocks {|st| st.quantity + item_quantity(st.item_id)}

      update_items {|it, det| det.balance + it.quantity }

      res = res && income.save
    end

    set_errors(inventory) unless res

    res
  end

  def valid_items_in?
    
  end

  def valid_items_out?

  end
end
