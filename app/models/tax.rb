# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Tax < ActiveRecord::Base
  # callbacks
  acts_as_org

  # before_save :create_or_update_item
  
  has_one :item, :as => :itemable

  # relationships
  belongs_to :organisation
  has_and_belongs_to_many :transactions

  #validations
  validates_presence_of :name, :abbreviation, :organisation_id
  validates_numericality_of :rate, :greater_than_or_equal_to => 0
  validates_numericality_of :rate, :less_than_or_equal_to => 100
  validates_associated :organisation

  attr_accessible :name, :abbreviation, :rate

  # scopes
  default_scope where( :organisation_id => OrganisationSession.organisation_id )

  def to_s
    "#{abbreviation} (#{rate}%)"
  end
private

  # Creates a realated item with tax
  # This method creates a special Unit that cannot be visible used for
  # the creation of an item
  def create_or_update_item
    if self.new_record?
      unless unit = Unit.invisible.find_by_name("tax")
        unit = create_unit
      end
      item = Item.new(:name => name, :unit_id => unit.id)
      item.visible = false
      self.item = item
    elsif self.changes[:name]
      self.item.name = name
    end
  end

  # Creates a new tax unit
  def create_unit
    unit = Unit.new(:name => 'tax', :symbol => "__tx" )
    unit.visible = false
    unit.save!
    unit
  end

  # Finds all invisible records
  def self.invisible
   where( :organisation_id => OrganisationSession.id, :visible => false )
  end

end 
