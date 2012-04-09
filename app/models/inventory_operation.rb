# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryOperation < ActiveRecord::Base

  before_create     { self.creator_id = UserSession.user_id }

  STATES = ["draft", "approved"]
  OPERATIONS = ["in", "out", "transin", "transout"]

  belongs_to :transaction
  belongs_to :store
  belongs_to :contact
  belongs_to :creator, :class_name => "User"
  belongs_to :transout, :class_name => "InventoryOperation"
  belongs_to :store_to, :class_name => "Store"
  belongs_to :project

  has_one    :transference, :class_name => 'InventoryOperation', :foreign_key => "transference_id"


  has_many   :inventory_operation_details, :dependent => :destroy
  has_many :stocks, :autosave => true

  accepts_nested_attributes_for :inventory_operation_details

  # Validations
  validates_presence_of :ref_number, :store_id
  validates_inclusion_of :operation, :in => OPERATIONS
  
  validates_presence_of :store_to, :if => :is_transference?

  OPERATIONS.each do |op|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{op}?
        operation === "#{op}"
      end
    CODE
  end

  with_options :if => :transout? do |inv|
    inv.validates_presence_of :store_to
  end

  def get_contact_list
    if operation == "in"
      Supplier.scoped
    else
      Client.scoped
    end
  end

  def is_transference?
    ["transin", "transout"].include?(operation)
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
      met = method_for_transaction_details

      self.contact_id = transaction.contact_id
      transaction.transaction_details.each do |det|
        inventory_operation_details.build(:item_id => det.item_id, :quantity => det.send(met))
      end
    end
  end

  def method_for_transaction_details
    case
    when(transaction.is_a?(Income) && out?) then :balance
    when(transaction.is_a?(Buy)    && in?)  then :balance
    when(transaction.is_a?(Income) && in?)  then :delivered
    when(transaction.is_a?(Income) && out?) then :delivered
    end
  end

  # Returns the hash of items
  def get_hash_of_items
    self.store.get_hash_of_items(:item_id => inventory_operation_details.map(&:item_id))
  end

  # Sets the details and creates the ref_number
  def set_transaction
    create_details
    create_ref_number
  end

  def hash_of_items
    store.hash_of_items(inventory_operation_details.map(&:item_id))
  end

  # Creates the ref number depending of the options
  def create_ref_number
    if transaction_id.present?
      seq = InventoryOperation.where(:transaction_id => transaction_id).size + 1
      self.ref_number = "#{transaction.ref_number}-#{"%02d" % seq}"
    else
      case operation
      when "in" then seq = "ING-"
      when "out" then seq = "EGR-"
      when "transout" then seq = "TRANS-EGR-"
      end
      #seq = operation == "in" ? "ING-" : "EGR-"
      seq << "%04d" % (store.inventory_operations.size + 1)
      self.ref_number = seq
    end
  end

  def change_transout_ref_number
    self.ref_number = self.ref_number.gsub("TRANS-EGR", "TRANS-IN")
  end

  # Returns the item for a transaction
  def transaction_item(item_id)
    @details ||= transaction.transaction_details.to_a
    @details.find {|det| det.item_id === item_id }
  end

  # Returns the delivered quantity for a transaction
  def delivered_quantity(item_id)
    item = transaction_item(item_id)
    item.quantity - item.balance
  end

  # Save for common in and out
  def save_operation
    ret = true

    self.class.transaction do

      unless in?
        return false unless check_valid_quantity
      end

      inventory_operation_details.each do |det|
        next if det.quantity === 0

        if det.quantity == 0
          det.errors[:quantity] = I18n.t("errors.messages.greater_than", :count => 0)
          ret = false
        end
        
        if in?
          q = available_stocks[det.item_id] + det.quantity
        else
          q = available_stocks[det.item_id] - det.quantity
        end

        store.stocks.build(:item_id => det.item_id, :quantity => q)
      end
    end

    ret = ( store.save && ret )
    ret = ( self.save && ret )

    raise ActiveRecord::Rollback unless ret

    ret
  end

  # Save method for transaction Income/Buy
  def save_transaction
    return false unless transaction
    ret = true
    self.project_id = transaction.project_id

    self.class.transaction do
      return false if transaction.draft? or ( transaction.is_a?(Income) and not(transaction.deliver?) )

      return false unless check_valid_quantity

      return false unless valid_transaction_items?

      return false if repeated_items?

      inventory_operation_details.each do |det|
        next if det.quantity == 0
        update_transaction_details_balance(det)
#puts "Updated transaction details balance #{det.item_id}:: #{det.quantity} "
        unless is_item_service?(det.item_id)
          if out?
            q = available_stocks[det.item_id] - det.quantity
          else
            q = available_stocks[det.item_id] + det.quantity
          end
          
          store.stocks.build(:item_id => det.item_id, :quantity => q)
        end
      end
      
      set_transaction_delivered
      
      set_transaction_devolution

      ret = ( store.save && ret )
      ret = ( self.save && ret )
      ret = ( transaction.save && ret )

      raise ActiveRecord::Rollback unless ret
    end

    ret
  end

  # Selects all items that have a quantity greater than 0
  def item_ids
    inventory_operation_details.select {|v| v.quantity > 0}.map(&:item_id)
  end

  protected

  # To determine if an item is service and not to update stock
  def is_item_service?(i_id)
    @service_item_ids ||= Item.service.where(:id => item_ids).values_of( :id )
    @service_item_ids.include?(i_id)
  end
  
  # sets the delivered if all the balances are 0
  def set_transaction_delivered
    if transaction.transaction_details.map(&:balance).uniq === [0]
      transaction.delivered = true
    else
      transaction.delivered = false
    end
  end

  def set_transaction_devolution
    case
    when( transaction.is_a?(Income) && in?)
      transaction.devolution = true
    when( transaction.is_a?(Buy) && out?)
      transaction.devolution = true
    end
  end

  # Returns a Hash with the available stocks {item_id => quantity}
  def available_stocks
    @h_s ||= Hash[store.stocks.where(:item_id => item_ids).values_of(:item_id, :quantity)]
    @h_stock ||= Hash[item_ids.map do |i_id|
      q = @h_s[i_id] ? @h_s[i_id] : 0
      [i_id, q]
    end]
  end

  # Checks if the items in the list are valid and not repeated
  def valid_transaction_items?
    trans_det_ids = transaction.transaction_details.map(&:item_id)

    inventory_operation_details.each do |det|
      unless trans_det_ids.include?(det.item_id)
        self.errors[:base] << I18n.t("errors.messages.inventory_operation.transaction_items")
        return false
      end
    end

    true
  end

  def repeated_items?
    h = Hash.new(0)
    inventory_operation_details.each do |det|
      h[det.item_id] += 1
    end


    if h.values.find {|v| v > 1 }
      self.errors[:base] << I18n.t("errors.messages.repeated_items")
      true
    end
  end

  # Check the quantity of items out
  def check_valid_quantity
    det_ids = transaction.transaction_details.map(&:item_id) if transaction_id.present?

    valid_det = true

    inventory_operation_details.each do |io_det|
      next if io_det.quantity == 0
 
      # quantity greater or equal to 0
      if io_det.quantity < 0
        io_det.errors[:quantity] << I18n.t("errors.messages.greater_than_or_equal_to", :count => 0)
        valid_det = false
      end

      # Valid stock quantity
      if out? and not(is_item_service?(io_det.item_id) )
        if available_stocks[io_det.item_id] < io_det.quantity
          io_det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.stock_quantity") 
          valid_det = false
        end
      end

      if transaction_id.present?
        valid_det = false unless valid_transaction_quantity(io_det)
      end
    end

    valid_det
  end

  private
  def trans_dets
    @trans_dets ||= transaction.transaction_details.to_a
  end

  def trans_item(i_id)
    trans_dets.find {|det| det.item_id === i_id }
  end

  def valid_transaction_quantity(io_det)
    t_det = trans_item(io_det.item_id)

  #puts "BUY #{transaction.is_a?(Buy)} check transaction quantity #{io_det.item_id} : #{io_det.quantity} || #{t_det.item_id} : #{t_det.balance}"
    # For operations of a transaction
    case true
    when transaction.is_a?(Income)
      if out? and io_det.quantity > t_det.balance
        io_det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.transaction_quantity")
        return false
      elsif in? and io_det.quantity > (t_det.quantity  - t_det.balance)
        io_det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.transaction_quantity")
        return false
      end
    when transaction.is_a?(Buy)
      if in? and io_det.quantity > t_det.balance
        io_det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.transaction_quantity")
        return false
      elsif out? and io_det.quantity > (t_det.quantity  - t_det.balance)
        io_det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.transaction_quantity")
        return false
      end
    end

    true
  end

  def update_transaction_details_balance(det)
    t_det = trans_item(det.item_id)

    case
      when( transaction.is_a?(Income) and out? )
        t_det.balance -= det.quantity
      when( transaction.is_a?(Income) and in? )
        t_det.balance += det.quantity
      when( transaction.is_a?(Buy) and in? )
        t_det.balance -= det.quantity
      when( transaction.is_a?(Buy) and out? )
        t_det.balance += det.quantity
    end

    # Updates the quantity delivered
    t_det.delivered = t_det.quantity - t_det.balance
  end

  # Calculates the total value for the current operation
  def inventory_transaction_value
    transaction_details = transaction.transaction_details.all
    inventory_operation_details.inject(0) do |sum, det|
      it = trans_item( det.item_id )
      sum += it.price * det.quantity
    end
  end

end
