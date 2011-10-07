# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Stock < ActiveRecord::Base
  acts_as_org

  before_create :update_last_and_set_minimum

  STATES = ["active", "inactive", "waiting"].freeze
  STATES.each do |met|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{met}?
        state === "#{met}"
      end
    CODE
  end

  belongs_to :store
  belongs_to :item
  belongs_to :user

  #validations
  validates_presence_of :store_id
  validates_numericality_of :minimum, :greater_than => 0, :allow_nil => true

  # Scopes
  default_scope where(:state => 'active')
  scope :minimums, where("stocks.quantity <= stocks.minimum")
  #scope :active, where(:state => 'active')

  delegate :name, :price, :code, :to_s, :type, :to => :item, :prefix => true

  # Sets the minimun for an Stock
  def self.new_minimum(item_id, store_id)
    Stock.org.find_by_item_id_and_store_id(item_id, store_id)
  end

  def self.minimum_list
    Stock.org.select("COUNT(item_id) AS items_count, store_id").where("quantity <= minimum").group(:store_id).count
  end

  # Creates a new instance with an item
  def save_minimum(minimum)
    if minimum.to_f < 0
      self.errors[:minimum] << I18n.t("errors.messages.greater_than", :count => 0)
      false
    else
      self.minimum = minimum.to_f
      self.user_id = UserSession.user_id
      self.save
    end
  end

  private

  def update_last_and_set_minimum
    s = Stock.org.find_by_item_id_and_store_id(self.item_id, self.store_id)
    if s
      self.minimum = s.minimum.to_f
      s.update_attribute(:state, 'inactive') if s
    else
      self.minimum = 0
    end
  end

end
