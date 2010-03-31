class Organisation < ActiveRecord::Base
  # callbacks
  after_create :create_taxes # There is an error with the relationship

  # relationships
  belongs_to :user
  belongs_to :country

  has_many :taxes, :class_name => "Tax", :dependent => :destroy
#  accepts_nested_attributes_for :tax_rates

  # validations
  validates_associated :user
  validates_associated :country

  validates_presence_of :name, :address, :phone, :user_id, :country_id
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id
  
  def to_s
    %Q(name)
  end

  # Sets the user for the current organisation
  def set_user(current_user_id)
    write_attribute(:user_id, current_user_id)
  end

protected
  # Adds the default taxes for each country
  def create_taxes
    country.taxes.each do |tax|
      taxes << Tax.new(tax)
    end
  end
end
