# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Item < ActiveRecord::Base

  #self.inheritance_column = :class_type

  ##########################################
  # Callbacks
  before_destroy :check_items_destroy

  ##########################################
  # Relationships
  belongs_to :unit
  has_many :prices
  has_many :stocks
  has_many :transaction_details
  has_many :inventory_operation_details
  
  serialize :money_status, Hash

  ##########################################
  # Validations
  validates_presence_of :name, :unit, :unit_id, :code
  validates :code, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, if: :for_sale?


  ##########################################
  # Delegates
  delegate :symbol, :name, to: :unit, prefix: true

  ##########################################
  # Scopes
  scope :active   , where(active: true)
  scope :json     , select("id, name, price")

  # Related scopes
  scope :income   , where(active: true, for_sale: true)
  scope :inventory, where(stockable: true)

  def to_s
    "#{code} - #{name}"
  end

  def label
    to_s
  end

  # Searches using ctype, and searches the name and code atributes
  def self.index(s_type = TYPES.first, options = {})
    query = [ ["name", "code"].map {|v| "items.#{v} ILIKE ?"}.join(" OR ") ] + Array.new(2, "%#{options[:search]}%")
    where(ctype: s_type).where(query)
  end

  def self.search(search)
    self.includes(:unit, :stocks).where("items.name ILIKE :s OR items.code ILIKE :s", s: "%#{search}%")
  end

  # Modifications for rubinius
  def self.simple_search(search, limit = 20)
    sc = self.where("code ILIKE :search OR name ILIKE :search", search: "%#{search}%")
    sc.limit(limit).values_of(:id, :code, :name, :price).map do |id, code, name, price|
      {id: id, code: code, name: name, price: price, label: "#{code} - #{name}", value: id}
    end
  end

  def self.with_stock(store_id, search)
    Item.joins(:stocks).select("items.id, items.name, items.code, stocks.quantity").active.inventory.
    where("items.code ILIKE :search OR items.name ILIKE :search", search: "%#{search}%").
    where("stocks.store_id = ? AND stocks.quantity > 0 AND stocks.state = 'active'", store_id)
  end

  # creates an array with values  [quantity, percentage]
  def discount_values
    return [] if self.discount.blank?
    self.discount.squish.split(" ").map { |v| v.split(":").map(&:to_f) }
  end

  # Sums the stocks of a item
  def total_stock
    stocks.inject(0) {|sum,st| sum += st.quantity }
  end

  # Returns the details for item kardex
  def kardex
    self.transaction_details.includes(:transaction).where("transactions.state != 'draft'")
  end

private
  # checks if there are any items on destruction
  def check_items_destroy
    if TransactionDetail.where(item_id: id).any? or InventoryOperationDetail.where(item_id: id).any?
      errors.add(:base, "El item es usado en otros registros relacionados")
      false
    else
      true
    end
  end

end
