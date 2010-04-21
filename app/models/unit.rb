class Unit < ActiveRecord::Base
  acts_as_org

  before_save :strip_attributes

  has_many :items

  default_scope :conditions => { :visible =>  true }

  attr_accessible :name, :symbol, :integer

  validates_presence_of :name, :symbol

  def integer?
    integer ? I18n.t("yes") : I18n.t("no")
  end

  def strip_attributes
    name.strip!
    symbol.strip!
  end

  # Retrives all invisible records
  def self.invisible
    Unit.with_exclusive_scope { where(:visible => false) }
  end

  # Retrives all records
  def self.all_records
    Unit.with_exclusive_scope { where("1=1") }
  end
end
