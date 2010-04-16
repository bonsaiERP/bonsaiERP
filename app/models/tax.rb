class Tax < ActiveRecord::Base

  # callbacks

  acts_as_org
  # before_create :create_item

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

end 
