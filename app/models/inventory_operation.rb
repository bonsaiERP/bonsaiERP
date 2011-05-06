# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base
  acts_as_org

  after_initialize  :set_operation, :if => :new_record?
  before_create     :set_stock
  before_validation :set_transaction_on_details, :if => 'transaction_id.present?'

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

  # Returns an array with the details fo the transaction
  def get_transaction_items
    transaction.transaction_details
  end

  # Creates the details depending if it has transaction
  def create_details
    if transaction_id.blank?
      inventory_operation_details.build
    else
      self.contact_id = transaction.contact_id
      transaction.transaction_details.each do |det|
        inventory_operation_details.build(:item_id => det.item_id, :quantity => det.balance)
      end
    end
  end

  # Returns the hash of items
  def get_hash_of_items
    self.store.get_hash_of_items(:item_id => inventory_operation_details.map(&:item_id))
  end

  private

  # sets the stock for items and set the total amount for the operation
  def set_stock
    transaction.set_trans(false) if transaction_id.present?

    inventory_operation_details.each do |det|
      next if det.quantity == 0

      st = store.stocks.find_by_item_id(det.item_id)
      q = st.blank? ? 0 : st.quantity

      st.update_attribute(:state, 'inactive') unless st.blank?
      q = operation == "in" ? q + det.quantity : q - det.quantity

      store.stocks.build(:item_id => det.item_id, :quantity => q, :state => 'active')
      update_quantity_of_transaction(det) if transaction_id.present?
    end

    if transaction_id.present?
      return false unless check_and_save_transaction
    end

    store.save
  end

  def check_and_save_transaction
    if valid_transaction
      transaction.update_attribute(:balance_inventory, transaction.balance_inventory - inventory_transaction_value)
    else
      false
    end
  end

  # Calculates the total value for the current operation
  def inventory_transaction_value
    transaction_details = transaction.transaction_details.all
    inventory_operation_details.inject(0) do |sum, det|
      it = transaction_details.find {|td| td.item_id == det.item_id }
      sum += it.price * det.quantity
    end
  end

  # Checks if there are any errors related to the transaction
  def valid_transaction
    ret = true
    inventory_operation_details.each do |det|
      unless det.errors.blank?
        return false
      end
    end

    ret
  end

  # Updates and validtes the quantiry for a transaction
  def update_quantity_of_transaction(det)
    it = transaction.transaction_details.find_by_item_id(det.item_id)

    if det.quantity > it.balance
      det.errors.add(:quantity, "Cantidad mayor a la permitida")
    elsif det.quantity > 0
      it.update_attribute(:balance, (it.balance - det.quantity) )
    end
  end

  # Sets the operation for
  def set_operation
    if transaction_id.present?
      if transaction.is_a? Income
        self.operation = "out"
      else
        self.operation = "in"
      end
    end
  end

  # Sets the transaction flag for details
  def set_transaction_on_details
    inventory_operation_details.each {|det| det.set_transaction = true }
  end

end
