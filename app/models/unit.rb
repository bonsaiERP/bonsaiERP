# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Unit < ActiveRecord::Base

  acts_as_org

  # callbacks
  before_save    :strip_attributes
  before_destroy :check_items_destroy

  # relationships
  belongs_to :organisation

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

  # Returns false if there are
  def check_items_destroy
    if Item.org.where(:unit_id => id).any?
      errors.add(:base, "Existen items que usan esta unidad de medidad")
      false
    else
      true
    end
  end

end
