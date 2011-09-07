# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Store < ActiveRecord::Base
  acts_as_org

  #include Models::Account::Base

  before_destroy :check_store_for_delete

  has_many :stocks#, :conditions => {:state => 'active'}
  has_many :inventory_operations

  validates_presence_of :name, :address
  validates_length_of :name, :minimum => 3
  validates_length_of :address, :minimum => 5

  # scopes
  scope :active, where(:active => true)

  def to_s
    name
  end

  def hash_of_items(ids)
    st = Stock.where(:store_id => id, "stocks.item_id" => ids)[:item_id, :quantity, :minimum]
    Hash[ids.map do |id|
      it = st.find {|v| v[0] === id}
      it = [id, 0, ""] unless it
      [id, {:quantity => it[1], :minimum => it[2]}]
    end]
  end

  # Returns a Hash of items with the item_id as key
  def get_hash_of_items(*args)
    options = args.extract_options!
    args = [:quantity] unless args.any?
    h = lambda {|v| Hash[args.map {|a| [a, v.send(a)] } ] }
    
    st = stocks
    st = st.where(options) if options

    items = options[:item_id].is_a?(Array) ? options[:item_id] : [options[:item_id]]

    Hash[
    items.map do |i_id|
      [i_id, {:quantity => 0}]
    end]
    #Hash[ st.includes(:item).map {|st| [st.item_id , h.call(st) ] } ]
  end

  private

  def check_store_for_delete
    if stocks.any? or inventory_operations.any?
      self.errors[:base] << "No es posible borrar debido a que tiene operaciones relacionadas"
      false
    else
      true
    end
  end
end
