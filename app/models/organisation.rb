class Organisation < ActiveRecord::Base
  # callbacks
  before_create :create_taxes # There is an error with the relationship
  before_create :create_link

  # relationships
  belongs_to :country

  has_many :taxes, :class_name => "Tax", :dependent => :destroy
  has_many :links
  has_many :users, :through => :links

  # validations
  validates_associated :country

  validates_presence_of :name, :address, :phone, :country_id
  validates_uniqueness_of :name, :scope => :user_key

  attr_protected :user_key
  
  def to_s
    %Q(name)
  end

  # Sets the user_id, needed to define the scope of uniquenes_of :name
  def set_user_key(key)
    write_attribute(:user_key, key)
  end

protected

  # Adds the default taxes for each country
  def create_taxes
    country.taxes.each do |tax|
      taxes << Tax.new(tax)
    end
  end

  # Creates the link to the user
  def create_link
    link = Link.new
    link.set_user_creator_role(user_key)
    links << link
  end
end
