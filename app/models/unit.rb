# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Unit < ActiveRecord::Base

  acts_as_org

  belongs_to :organisation
  before_save :strip_attributes

  has_many :items

  #default_scope :conditions => { :organisation_id => OrganisationSession.id }

  attr_accessible :name, :symbol, :integer

  validates_presence_of :name, :symbol

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

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
