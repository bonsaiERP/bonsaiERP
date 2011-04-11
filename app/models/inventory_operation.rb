# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base
  acts_as_org

  STATES = ["draft", "approved"]

  belongs_to :transaction
  belongs_to :store

  has_many   :inventory_operation_details, :dependent => :destroy

  accepts_nested_attributes_for :inventory_operation_details
end
