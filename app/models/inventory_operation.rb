# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base
  acts_as_org

  STATES = ["draft", "approved"]
  OPERATIONS = ["in", "out", "transference"]

  belongs_to :transaction
  belongs_to :store
  belongs_to :contact

  has_many   :inventory_operation_details, :dependent => :destroy

  accepts_nested_attributes_for :inventory_operation_details

  def get_contact_list
    if operation == "in"
      Supplier.org
    else
      Client.org
    end
  end

  def contact_label
    if operation == "in"
      "Proveedor"
    else
      "Cliente"
    end
  end

end
