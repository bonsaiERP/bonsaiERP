# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Store < ActiveRecord::Base

  #include Models::Account::Base

  before_destroy :check_store_for_delete

  has_many :stocks, -> { where(active: true) }, autosave: true
  has_many :inventories

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name, minimum: 3
  validates_length_of :address, minimum: 5, allow_blank: true
  validates_lengths_from_database

  # scopes
  scope :active, -> { where(active: true) }
  scope :notin, -> (st_id) { where.not(id: st_id) }

  def to_s
    name
  end

  def hash_of_items(item_ids)
    st = stocks.where(:item_id => item_ids).pluck(:item_id, :quantity, :minimum)

    Hash[item_ids.map do |i_id|
      it = st.find {|v| v[0] === i_id }
      it = [i_id, 0, ""] if it.nil?

      [i_id, {:quantity => it[1], :minimum => it[2]}]
    end]
  end

  # Returns a Hash of items with the item_id as key
  #def get_hash_of_items(*args)
  #  options = args.extract_options!
  #  args = [:quantity] unless args.any?
  #  h = lambda {|v| Hash[args.map {|a| [a, v.send(a)] } ] }

  #  st = stocks
  #  st = st.where(options) if options

  #  items = options[:item_id].is_a?(Array) ? options[:item_id] : [options[:item_id]]

  #  Hash[
  #  items.map do |i_id|
  #    [i_id, {:quantity => 0}]
  #  end]
  #  #Hash[ st.includes(:item).map {|st| [st.item_id , h.call(st) ] } ]
  #end

  def self.get_names_hash
    @names_hash ||= Hash[Store.pluck(:id, :name)]
  end

private

  def check_store_for_delete
    if stocks.any? or inventories.any?
      self.errors[:base] << I18n.t('errors.messages.store.destroy')
      return false
    end
  end
end
