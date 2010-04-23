class Item < ActiveRecord::Base
  acts_as_org

  belongs_to :unit

  belongs_to :itemable, :polymorphic => true

  default_scope :conditions => { :visible => true }

  attr_accessible :name, :unit_id, :product, :stockable, :description

  # Validations
  validates_presence_of :name, :unit_id
  validates_associated :unit

  def to_s
    name
  end

  # scoped find method
  def self.invisible
    Item.with_exclusive_scope  { where(:visible => false) }
  end

  # scoped find method
  def self.all_records
    Item.with_exclusive_scope  { where("1=1") }
  end

end
