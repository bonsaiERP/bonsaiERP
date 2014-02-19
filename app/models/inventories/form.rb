# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Form < BaseForm
  attribute :store_id, Integer
  attribute :date, Date
  attribute :ref_number, String
  attribute :description, String
  attribute :inventory_details_attributes

  attr_writer :inventory

  delegate :inventory_details, :details,
           :inventory_details_attributes=,
           to: :inventory

  delegate :stocks, :stock, :stocks_to, :detail, :item_ids, :item_quantity, to: :klass_details

  validates_presence_of :store, :inventory
  validate :unique_item_ids
  validate :at_least_one_item

  def store
    @store ||= Store.active.where(id: store_id).first
  end

  def inventory
    @inventory ||= begin
      i = Inventory.new(
        store_id: store_id, date: date, description: description,
        inventory_details_attributes: get_inventory_details,
        operation: operation
      )
      i.set_ref_number
      i
    end
  end

  def details_serialized
    details.map do |v|
      v.attributes.merge(stock_with_items(v.item_id).attributes)
    end
  end

  private

    def stock_with_items(item_id)
      stock_items_hash.fetch(item_id) { StockWithItem.new }
    end

    def stock_items_hash
      @stock_items_hash ||= begin
         res =  store.stocks.includes(:item).where(item_id: details.map(&:item_id))
         Hash[ res.map { |v| [v.item_id, StockWithItem.new(v)] }]
      end
    end

    # Saves and in case there are errors in inventory these are set on
    # the Iventories::Form instance
    def save(&b)
      res = valid? && @inventory.valid?
      res = commit_or_rollback { b.call } if res

      set_errors(@inventory) unless res

      res
    end

    def get_inventory_details
      if inventory_details_attributes.nil?
        []
      else
        inventory_details_attributes
      end
    end

    def klass_details
      @klass_details ||= Inventories::Details.new(@inventory)
    end

    def self.public_attributes
      [:store_id, :date, :description]
    end

    def operation; end

    def unique_item_ids
      self.errors.add(:base, I18n.t("errors.messages.item.repeated_items")) unless UniqueItem.new(@inventory).valid?
    end

    def at_least_one_item
      self.errors.add(:base, I18n.t("errors.messages.inventory.at_least_one_item"))  if details.empty?
    end
end

class StockWithItem
  attr_accessor :unit, :item, :stock

  def initialize(obj = nil)
    @item = obj.item_to_s
    @unit = obj.item_unit_symbol
    @stock = obj.quantity
  rescue
    @stock = BigDecimal.new(0)
  end

  def attributes
    { item: item, unit: unit, stock: stock }
  end
end
