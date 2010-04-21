class Tax < ActiveRecord::Base

  # callbacks

  acts_as_org
  before_save :update_or_create_item
  
  has_one :item, :as => :itemable

  # relationships
  belongs_to :organisation

  #validations
  validates_presence_of :name, :abbreviation
  validates_numericality_of :rate, :greater_than_or_equal_to => 0
  validates_numericality_of :rate, :less_than_or_equal_to => 100
  validates_associated :organisation

  attr_accessible :name, :abbreviation, :rate

  # Used to set when organisation is created
#  def set_organisation_id(org_id)
#    write_attribute(:organisation_id, organisation_id)
#  end
#  alias set_organisation_id= set_organisation_id
private

  # Creates a realated item with tax
  # This method creates a special Unit that cannot be visible used for
  # the creation of an item
  def update_or_create_item
    if self.new_record?
      unless unit = Unit.invisible.find_by_name("tax")
        unit = Unit.new(:name => 'tax', :symbol => "__tx" )
        unit.visible = false
        unit.save
      end
      create_item(unit)
    elsif not self.changes[:name]
      self.item.name = name
    end
  end

  # Sets the item
  # @param [Unit] Instance of Unit model
  def create_item(unit)
    item = Item.new(:name => name, :unit_id => unit.id)
    self.item = item
  end
end 
