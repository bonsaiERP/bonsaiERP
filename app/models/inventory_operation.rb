# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base
  acts_as_org

  before_create :set_stock

  STATES = ["draft", "approved"]
  OPERATIONS = ["in", "out", "transference"]

  belongs_to :transaction
  belongs_to :store
  belongs_to :contact

  has_many   :inventory_operation_details, :dependent => :destroy

  accepts_nested_attributes_for :inventory_operation_details

  validates_presence_of :ref_number, :date, :contact_id, :store_id

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

  # Creates the details depending if it has transaction
  def create_details
    if transaction_id.blank?
      inventory_operation_details.build
    else
      transaction.transaction_details.each do |det|
        inventory_operation_details.build(:item_id => det.item_id, :quantity => det.balance)
      end
    end
  end

  private
  # sets the stock for items
  def set_stock
    inventory_operation_details.each do |det|
      st = store.stocks.find_by_item_id(det.item_id)

      c, q = st.blank? ? [0, 0] : [st.unitary_cost, st.quantity]
      st.update_attribute(:state, 'inactive') unless st.blank?

      cost = calculate_cost(c, q, det.unitary_cost, det.quantity)
      q = operation == "in" ? q + det.quantity : q - det.quantity

      store.stocks.build(:item_id => det.item_id, :unitary_cost => cost, :quantity => q, :state => 'active')
      #update_transaction_detail(det) if transaction_id.present?
    end

    store.save
  end

  # Calculates the cost according the quantity and if is IN/OUT
  def calculate_cost(c1, q1, c2, q2)
    if operation == "in"
      (c1*q1 + c2*q2)/ (q1 + q2)
    else
      c1
    end
  end
end
