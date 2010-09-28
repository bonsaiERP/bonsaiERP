class Item < ActiveRecord::Base

  acts_as_org

  belongs_to :unit

  # belongs_to :itemable, :polymorphic => true

  attr_accessible :name, :unit_id, :code, :product, :stockable, :description

  # Validations
  validates_presence_of :name, :unit_id, :code
  validates_associated :unit
  validates :code, :uniqueness => { :scope => :organisation_id }

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

  def to_s
    name
  end

  def self.invisible
    Item.where( :organisation_id => OrganisationSession.id, :visible => false )
  end

end
