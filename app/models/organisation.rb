class Organisation < ActiveRecord::Base
  # callbacks
  before_create :set_user
  before_create :create_taxes # There is an error with the relationship
  before_create :create_link


  # relationships
  belongs_to :country
  belongs_to :currency

  has_many :taxes, :class_name => "Tax", :dependent => :destroy
  has_many :links
  has_many :users, :through => :links

  # validations
  validates_associated :country
  validates_associated :currency

  validates_presence_of :name, :address, :phone, :country_id, :currency_id
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id
  
  def to_s
    %Q(name)
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
    link.set_user_creator_role(user_id)
    links << link
  end

  # Sets the user_id, needed to define the scope of uniquenes_of :name
  def set_user
    write_attribute(:user_id, UserSession.current_user.id)
  end
end
