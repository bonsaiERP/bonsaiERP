# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Item < ActiveRecord::Base

  self.inheritance_column = :class_type

  ##########################################
  # Callbacks
  before_destroy :check_items_destroy

  TYPES = ["item", "expense", "product", "service"]

  ##########################################
  # Relationships
  belongs_to :unit
  has_many :prices
  has_many :stocks
  has_many :transaction_details
  has_many :inventory_operation_details
  

  ##########################################
  # Attributes
  attr_readonly :type, :ctype

  ##########################################
  # Validations
  validates_presence_of :name, :unit, :unit_id, :code
  validates :code, :uniqueness => true
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }, if: :for_sale?


  ##########################################
  # Delegates
  delegate :symbol, :name, :to => :unit, :prefix => true

  ##########################################
  # Scopes
  scope :active   , where(:active => true)
  scope :json     , select("id, name, price")

  # Related scopes
  scope :income   , where(active: true, for_sale: true)
  #scope :buy      , where(["ctype IN (?) AND active = ?", ['item', 'product', 'service'], true])
  #scope :expense  , where(["ctype IN (?) AND active = ?", ['expense'], true])
  scope :inventory, where(stockable: true)
  scope :for_sale, where(for_sale: true)
  scope :service  , where(:ctype => 'service')

  ##########################################
  # Methods
  TYPES.each do |met|
    class_eval <<-CODE, __FILE__, __LINE__ + 1
      def #{met}?
        "#{met}" === ctype
      end
    CODE
  end

  def to_s
    "#{code} - #{name}"
  end

  # Method to get the localized types
  def self.get_types(sc = nil)
    if sc.blank?
      ["Enseres", "Item de Gasto", "Producto", "Servicio"].zip(TYPES)
    else
      get_scoped_types(sc)
    end
  end

  # Instanciates an item based on the ctype
  def self.new_item(params)
    if params[:ctype] == "service"
      ItemService.new(params)
    else
      Item.new(params)
    end
  end

  # gets the item scope
  def self.get_scoped_types(sc)
    case sc
    when "income"
      ["Producto", "Servicio"].zip(['product', 'service'])
    when "buy"
      ["Item", "Producto", "Servicio"].zip( ["item", "product", "service"] )
    when "expense"
      ["Item de gasto"].zip(["expense"])
    when "inventory"
      ["Item", "Producto"].zip( ["item", "product"] )
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

  # Searches using ctype, and searches the name and code atributes
  def self.index(s_type = TYPES.first, options = {})
    query = [ ["name", "code"].map {|v| "items.#{v} ILIKE ?"}.join(" OR ") ] + Array.new(2, "%#{options[:search]}%")
    where(:ctype => s_type).where(query)
  end

  def self.search(params)
    self.includes(:unit, :stocks).where("items.name ILIKE :search OR items.code ILIKE :search", :search => "%#{params[:search]}%")
  end

  # Modifications for rubinius
  def self.simple_search(search, limit = 20)
    sc = self.where("code ILIKE :search OR name ILIKE :search", :search => "%#{search}%")
    sc.limit(limit).values_of(:id, :code, :name, :price).map do |id, code, name, price|
      {:id => id, :code => code, :name => name, :price => price, :label => "#{code} - #{name}", :value => id}
    end
  end

  def self.with_stock(store_id, search)
    Item.joins(:stocks).select("items.id, items.name, items.code, stocks.quantity").active.inventory.
    where("items.code ILIKE :search OR items.name ILIKE :search", :search => "%#{search}%").
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


  # Validations for discount
  def validate_discount
    return true if self.discount.blank?
    if self.discount =~ /^([+-]?[0-9]+)(\.\d)?$/
      validate_discount_number
    else
      validate_discount_range
    end
  end

  # checks if there are any items on destruction
  def check_items_destroy
    if TransactionDetail.where(:item_id => id).any? or InventoryOperationDetail.where(:item_id => id).any?
      errors.add(:base, "El item es usado en otros registros relacionados")
      false
    else
      true
    end
  end

  def check_valid_unit_id
    unless Unit.find_by_id(unit_id)
      self.errors[:unit_id] << I18n.t("errors.messages.invalidkeys")
      return false
    end
  end

end
