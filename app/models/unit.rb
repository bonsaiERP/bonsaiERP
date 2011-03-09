# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Unit < ActiveRecord::Base

  acts_as_org

  # relationships
  belongs_to :organisation
  before_save :strip_attributes

  has_many :items

  attr_accessible :name, :symbol, :integer

  # validations
  validates_presence_of :name, :symbol


  def to_s
    "#{name} (#{symbol})"
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
