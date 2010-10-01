# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Item < ActiveRecord::Base

  TYPES = ['Item', 'Product', 'Service']

  acts_as_org
  # acts_as_taggable_on :tags
  acts_as_taggable

  belongs_to :unit

  # belongs_to :itemable, :polymorphic => true

  attr_accessible :name, :unit_id, :code, :stockable, :description, :price, :discount, :tag_list, :ctype

  # Validations
  validates_presence_of :name, :unit_id, :code
  validates_associated :unit
  validates :ctype, :presence => true, :inclusion => { :in => TYPES }
  validates :code, :uniqueness => { :scope => :organisation_id }
  validates :price, :numericality => { :greater_than_or_equal_to => 0, :if => lambda { |i| i.product? } }
  #validates :discount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100 }
  validate :validate_discount


  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

  def to_s
    name
  end

  def self.invisible
    Item.where( :organisation_id => OrganisationSession.id, :visible => false )
  end

  # validation for Services or products
  def product?
    [1, 2].map { |i| TYPES[i] }.include? self.ctype
  end 

  # Returns the recular expression for rang
  #
  # # Returns the recular expression for range
  def self.reg_discount_range
    reg_num = "[\\d]+(\\.[\\d]+)?"
    reg_per = "[\\d]+(\\.\\d)?"
    Regexp.new("^(#{reg_num}:#{reg_per}\\s+)*(#{reg_num}:#{reg_per}\\s*)?$")
  end

private
  # Validations for discount
  def validate_discount
    if self.discount =~ /^([+-]?[0-9]+)(\.\d)?$/
      validate_discount_number
    else
      validate_discount_range
    end
  end

  # Validates the discount if it is a number
  def validate_discount_number
    disc = self.discount.to_f
    if disc < 0
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.greater_than_or_equal_to", :count => 0))
    elsif disc > 100
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.less_than_or_equal_to", :count => 100))
    end
  end


  # validates the discount if it is a range
  def validate_discount_range
    if self.discount =~ self.class.reg_discount_range and !self.discount.blank?
      validate_discount_range_values
    else
      self.errors.add(:discount, I18n.t("activerecord.errors.messages.invalid") )
    end
  end

  # Validates that all values within a range are possitive and the percentage is less than 0
  # [number]:[percentage]
  # A translation for activerecord.errors.messages.invalid_range_percentage must be added
  def validate_discount_range_values
    self.discount.squish.split(" ").map { |v| v.split(":").map(&:to_f) }.each do |val, per|
      if per > 100
        self.errors.add(:discount, I18n.t("activerecord.errors.messages.invalid_range_percentage"))
        break
      end
    end
  end

end
