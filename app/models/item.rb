class Item < ActiveRecord::Base

  acts_as_org

  belongs_to :unit

  # belongs_to :itemable, :polymorphic => true


  attr_accessible :name, :unit_id, :product, :stockable, :description

  # Validations
  validates_presence_of :name, :unit_id
  validates_associated :unit

  scope :all, :conditions => { :organisation_id => OrganisationSession.id, :visible => true }

  def to_s
    name
  end

  def self.invisible
    Item.where( :organisation_id => OrganisationSession.id, :visible => false )
  end

end
