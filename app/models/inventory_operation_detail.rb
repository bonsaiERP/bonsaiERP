# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperationDetail < ActiveRecord::Base
  acts_as_org

  belongs_to :inventory_operation
  belongs_to :item

  validates_presence_of :item_id, :quantity
end
