# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Stock < ActiveRecord::Base
  acts_as_org

  before_create :update_last

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

  #validations
  validates_numericality_of :minimum, :greater_than => 0, :allow_nil => true

  default_scope where(:state => 'active')
  #scope :active, where(:state => 'active')

  delegate :name, :price, :code, :to_s, :type, :to => :item, :prefix => true

  # Creates a new instance with an item
  def self.new_item(params = {})
    s = Stock.org.find_by_store_id_and_item_id(params[:store_id], params[:item_id])

    if s
      params[:minimum] ||= s.minimum
      Stock.new(:item_id => s.item_id, :quantity => s.quantity, :minimum => params[:minimum])
    else
      false
    end
  end

  private
    def update_last
      s = Stock.org.find_by_item_id(self.item_id)
      s.update_attribute(:state => 'inactive')
    end

end
