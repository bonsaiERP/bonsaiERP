# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::InventoryOperation
  class Transference
    attr_accessor :store_out, :store_in
    attr_reader :inventory_operation_out, :inventory_operation_in
    # Recives two store models to make the transference, one is the sender and the othre the reciever
    def initialize(params)
      @inventory_operation_out = ::InventoryOperation.new(params)
      @inventory_operation_out.operation = 'transout'
      @inventory_operation_out.create_ref_number unless params[:ref_number].present?
    end

    # Saves the transference
    # @param params # Attributes for transference
    def make_transference
      ret = true
      check_stores
      check_items

      return false if @inventory_operation_out.errors.any?
      # Save
      InventoryOperation.transaction do
        create_inventory_operation_in
        
        ret = @inventory_operation_out.save

        @inventory_operation_in.transference_id = @inventory_operation_out.id
        ret = ret && @inventory_operation_in.save

        update_stocks if ret
        @inventory_operation_out.transference_id = @inventory_operation_in.id
        ret = ret && @inventory_operation_out.save

        raise ActiveRecord::Rollback unless ret
      end

      ret
    end

    def create_inventory_operation_in
      params = {
        :ref_number => @inventory_operation_out.ref_number,
        :contact_id => @inventory_operation_out.contact_id,
        :store_id => @inventory_operation_out.store_to_id,
        :store_to_id => @inventory_operation_out.store.id
      }
      @inventory_operation_in = ::InventoryOperation.new(params)
      @inventory_operation_in.operation = "transin"

      @inventory_operation_out.inventory_operation_details.each do |det|
        @inventory_operation_in.inventory_operation_details.build(:item_id => det.item_id, :quantity => det.quantity)
      end

      @inventory_operation_in.change_transout_ref_number
    end

    def update_stocks
      item_ids = @inventory_operation_out.inventory_operation_details.map(&:item_id)
      stocks_from = Hash[Stock.where(:store_id => @inventory_operation_out.store_id, :item_id => item_ids.uniq).values_of(:item_id, :quantity)]
      stocks_to = Hash[Stock.where(:store_id => @inventory_operation_out.store_to_id, :item_id => item_ids.uniq).values_of(:item_id, :quantity)]

      store_id    = @inventory_operation_out.store_id
      store_to_id = @inventory_operation_out.store_to_id

      @inventory_operation_out.inventory_operation_details.each do |det|
        qty = stocks_from[det.item_id] - det.quantity
        Stock.create!(:store_id => store_id, :quantity => qty, :item_id => det.item_id)

        qty = stocks_to[det.item_id].present? ? stocks_to[det.item_id] + det.quantity : det.quantity
        Stock.create!(:store_id => store_to_id, :quantity => qty, :item_id => det.item_id)
      end
    end

    # Checks that both stores from - to exists
    def check_stores
      store_id = @inventory_operation_out.store_id
      store_to_id = @inventory_operation_out.store_to_id

      @inventory_operation_out.errors[:store_id] << I18n.t("errors.messages.inventory_operation.invalid_store") unless Store.where(:id => store_id).any?
      @inventory_operation_out.errors[:store_to_id] << I18n.t("errors.messages.inventory_operation.invalid_store") unless Store.where(:id => store_to_id).any?
    end

    # checks the items and the quantity
    def check_items
      check_valid_items
      check_repeated_items 
      check_stock
    end

    def check_repeated_items
      h, err = {}, false
      @inventory_operation_out.inventory_operation_details.each do |det|
        if h[det.item_id]
          det.errors[:item_id] = I18n.t("errors.messages.inventory_operation_detail.repeated_item") 
          err = true
        end
        h[det.item_id] = h[det.item_id] ? h[det.item_id] + 1 : 1
      end

      @inventory_operation_out.errors[:base] = I18n.t("errors.messages.repeated_items") if err
    end

    def check_valid_items
      @valid_items = true
      item_ids = @inventory_operation_out.inventory_operation_details.map(&:item_id)

      item_ids = item_ids.uniq.compact
      if item_ids.empty?
        @inventory_operation_out.errors[:base] << I18n.t("errors.messages.inventory_operation.empty_items")
        return false
      end

      tot = Stock.where(:store_id => @inventory_operation_out.store_id, :item_id => item_ids.uniq).count
      unless tot == item_ids.uniq.count
        @inventory_operation_out.errors[:base] = I18n.t("errors.messages.inventory_operation.invalid_item")
        @valid_items = false
      end
    end

    def check_stock
      if @valid_items
        item_ids = @inventory_operation_out.inventory_operation_details.map(&:item_id)
        stocks ||= Hash[Stock.where(:store_id => @inventory_operation_out.store_id, :item_id => item_ids.uniq).values_of(:item_id, :quantity)]

        err = false
        @inventory_operation_out.inventory_operation_details.each do |det|
          if det.quantity > stocks[det.item_id]
            err = true
            det.errors[:quantity] << I18n.t("errors.messages.inventory_operation_detail.stock_quantity")
          end
        end

        @inventory_operation_out.errors[:base] << I18n.t("errors.messages.inventory_operation.stock_quantity") if err
      end
    end
  end
end
