# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Store < ActiveRecord::Base
  acts_as_org

  before_destroy :check_store_for_delete

  has_many :stocks, :conditions => {:state => 'active'}
  has_many :inventory_operations

  validates_presence_of :name, :address

  def to_s
    name
  end

  # Returns a Hash of items with the item_id as key
  def get_hash_of_items(*args)
    options = args.extract_options!
    args = [:quantity] unless args.any?
    h = lambda {|v| Hash[args.map {|a| [a, v.send(a)] } ] }
    
    st = stocks
    st = st.where(options) if options

    Hash[ st.includes(:item).map {|st| [st.item_id , h.call(st) ] } ]
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
