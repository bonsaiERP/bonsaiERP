# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Inventories::Form < BaseForm
  attribute :store_id, Integer
  attribute :date, Date
  attribute :ref_number, String
  attribute :description, String
  attribute :inventory_details_attributes, Array

  attr_writer :inventory

  delegate :inventory_details, :details,
           :inventory_details_attributes=,
           to: :inventory

  delegate :stocks, :detail, :item_quantity, to: :klass_details

  validates_presence_of :store, :inventory
  validate :unique_item_ids

  def store
    @store ||= Store.active.where(id: store_id).first
  end

  def inventory
    @inventory ||=
      begin
      i = Inventory.new(
        store_id: store_id, date: date, description: description,
        inventory_details_attributes: inventory_details_attributes,
        operation: operation
      )
      i.set_ref_number
      i
    end
  end

private
  def save(&b)
    res = valid? && @inventory.valid?
    res = commit_or_rollback { b.call } if res

    set_errors(@inventory) unless res

    res
  end

  def valid_stock?(stock)
    stock.quantity >= 0
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
end
