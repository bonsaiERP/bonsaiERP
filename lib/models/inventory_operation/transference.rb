# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module Models::InventoryOperation
  class Transference
    attr_accessor :store_out, :store_in
    attr_reader :inventory_operation_out, :inventory_operation_in
    # Recives two store models to make the transference, one is the sender and the othre the reciever
    def initialize(params)
      @inventory_operation_out = InventoryOperation.new(params)
      @inventory_operation_out.operation = 'transout'
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
        ret = @inventory_operation_out.save
        ret = @inventory_operation_in && ret
        raise ActiveRecord::Rollback unless ret
      end

      ret
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
      unless tot == item_ids.uniq
        @inventory_operation_out.errors[:base] = I18n.t("errors.messages.inventory_operation.invalid_item")
        @valid_items = false
      end
    end

    def check_stock
      if @valid_items
        item_ids = @inventory_operation_out.inventory_operation_details.map(&:item_id)
        stocks ||= Hash[Stock.where(:store_id => @inventory_operation_out.store_id, :item_id => item_ids.uniq).values_of(:id, :quantity)]

        @inventory_operation_out.inventory_operation_details.each do |det|
          if det.quantity > stocks[det.item_id]
            det.errors[:quantity] = I18n.t("errors.messages.inventory_operation_detail.stock_quantity")
          end
        end
      end
    end
  end
end
