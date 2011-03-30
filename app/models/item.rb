# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Item < ActiveRecord::Base

  #before_save :set_stockable
  after_save     :create_price
  before_destroy :check_items

  TYPES = ["item", "expense", "service", "product"]


  acts_as_org
  #acts_as_taggable

  # relationships
  belongs_to :unit
  has_many :prices
  has_many :transaction_details

  # belongs_to :itemable, :polymorphic => true
  

  attr_accessible :name, :unit_id, :code, :description, :price, :discount, :tag_list, :unitary_cost, :ctype, :active

  # Validations
  validates_presence_of :name, :unit_id, :code
  validates_associated :unit
  validates_numericality_of :unitary_cost, :greater_than_or_equal_to => 0
  validates :ctype, :presence => true, :inclusion => { :in => TYPES }
  validates :code, :uniqueness => { :scope => :organisation_id }
  validates :price, :numericality => { :greater_than_or_equal_to => 0, :if => lambda { |i| i.price.present? } }
  validate :validate_discount


  # scopes
  #default_scope where(:active => true)
  scope :active, where(:active => true)

  scope :json   , select("id, name, price")

  scope :income , where(["ctype IN (?) AND active = ?", ['service', 'product'], true])
  scope :buy    , where(["ctype IN (?) AND active = ?", ['item', 'product', 'service'], true])
  scope :expense, where(["ctype IN (?) AND active = ?", ['expense'], true])

  def to_s
    "#{code} - #{name}"
  end

  # Method to get the localized types
  def self.get_types
    case I18n.locale
    when :es
      ["Insumo", "Item de Gasto", "Servicio", "Producto"].zip(TYPES)
    end
  end

  # gets the localized type for the item
  def get_type
    self.class.get_types.find {|v| v.last == self.ctype }.first
  end

  # validation for Services or products
  #def product?
  #  TYPES.slice(2, 2).include? self.ctype
  #end 

  # Returns the recular expression for rang
  #
  # # Returns the recular expression for range
  def self.reg_discount_range
    reg_num = "[\\d]+(\\.[\\d]+)?"
    reg_per = "[\\d]+(\\.\\d)?"
    Regexp.new("^(#{reg_num}:#{reg_per}\\s+)*(#{reg_num}:#{reg_per}\\s*)?$")
  end

  # creates an array with values  [quantity, percentage]
  def discount_values
    return [] if self.discount.blank?
    self.discount.squish.split(" ").map { |v| v.split(":").map(&:to_f) }
  end

private

  # Creates a price to check in the history
  def create_price 
    Price.create_from_item(self)
  end

  # Validations for discount
  def validate_discount
    return true if self.discount.blank?
    if self.discount =~ /^([+-]?[0-9]+)(\.\d)?$/
      validate_discount_number
    else
      validate_discount_range
    end
  end

  # Validates the discount if it is a number
  def validate_discount_number
    disc = self.discount.to_f
    if disc < 0
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.greater_than_or_equal_to", :count => 0))
    elsif disc > 100
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.less_than_or_equal_to", :count => 100))
    end
  end


  # validates the discount if it is a range
  def validate_discount_range
    if self.discount =~ self.class.reg_discount_range and !self.discount.blank?
      validate_discount_range_values
    else
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.invalid") )
    end
  end

  # Validates that all values within a range are possitive and the percentage is less than 0
  # [number]:[percentage]
  # A translation for activerecord.errors.messages.invalid_range_percentage must be added
  def validate_discount_range_values
    curr_val = curr_per = 0
    first = true
    discount_values.each do |val, per|
      #if per > 100
      #  self.errors.add(:discount, I18n.t("activerecord.errors.messages.invalid_range_percentage"))
      #  break
      #end
      unless first
        if val <= curr_val or per <= curr_per
          self.errors.add(:discount, I18n.t("activerecord.errors.messages.invalid_range_secuence"))
          break
        end
      end
      first = false
      curr_val, curr_per = val, per
    end
  end

  # checks if there are any items on destruction
  def check_items_destroy
    if TransactionDetail.org.where(:item_id => id).any
      errors.add(:base, "El item es usado en otros registros relacionados")
      false
    else
      true
    end
  end

  #def set_stockable
  #  self.stockable = ( self.ctype != 'Service' )
  #  # Must return true, sometimes assigment is false and returns false so the
  #  # transaction rollsback
  #  true
  #end
end
