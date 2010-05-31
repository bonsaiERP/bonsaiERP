class Unit < ActiveRecord::Base
  include UUIDHelper

  acts_as_org

  before_save :strip_attributes

  has_many :items

  #default_scope :conditions => { :organisation_id => OrganisationSession.id }

  attr_accessible :name, :symbol, :integer

  validates_presence_of :name, :symbol

  scope :all, :conditions => { :visible => true, :organisation_id => OrganisationSession.id }
  #scope :invisible, :conditions => { :visible => false, :organisation_id => OrganisationSession.id }

  def to_s
    %Q(#{name} (#{symbol}))
  end

  def integer?
    # integer ? I18n.t("yes") : I18n.t("no")
    integer ? "Si" : "No"
  end

  # Retrives all invisible records
  def self.invisible
    Unit.where(:visible => false, :organisation_id => OrganisationSession.id )
  end
#
#  # Retrives all records
#  def self.all_records
#    Unit.with_exclusive_scope { where("1=1") }
#  end

protected
  def strip_attributes
    name.strip!
    symbol.strip!
  end

end
