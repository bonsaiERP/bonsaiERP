# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Stock < ActiveRecord::Base
  belongs_to :store
  belongs_to :item
  belongs_to :user

  #validations
  validates_presence_of :store, :store_id, :item, :item_id
  validates_numericality_of :minimum, greater_than_or_equal_to: 0, allow_nil:  true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :store_house, -> (store_id) { where(store_id: store_id) }
  scope :mins, -> { where("stocks.quantity < stocks.minimum") }
  scope :item_like, -> (s) { active.joins(:item).where("items.name ILIKE :s OR items.code ILIKE :s", s: "%#{s}%") }
  scope :available_items, -> (store_id, s) { item_like(s).where("store_id=? AND quantity > 0", store_id) }

  delegate :name, :price, :code, :to_s, :type, :unit_symbol, to: :item, prefix: true

  # Sets the minimun for an Stock
  def self.new_minimum(item_id, store_id)
    Stock.find_by_item_id_and_store_id(item_id, store_id)
  end

  def self.minimum_list
    Stock.select("COUNT(item_id) AS items_count, store_id").where("quantity <= minimum").group(:store_id).count
  end

  # Creates a new instance with an item
  def save_minimum(min)
    min = min.is_a?(Numeric) ? min.to_d : min.to_s.to_d
    if min < 0
      self.errors[:minimum] << I18n.t("errors.messages.greater_than", count: 0)
      false
    else
      self.minimum = min
      self.user_id = UserSession.id
      self.save
    end
  end
end
