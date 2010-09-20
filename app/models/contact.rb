class Contact < ActiveRecord::Base
  acts_as_org

  # callbacks
  before_save :create_or_update_item

  has_one :item, :as => :itemable, :dependent => :destroy

  validates_presence_of :name, :address

  attr_accessible :name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :type
  
  TYPES = [ 'Client', 'Supplier' ]

  
  # scopes
  #scope :all, :conditions => { :organisation_id => OrganisationSession.id }

private
  def create_or_update_item
    if self.new_record?
      unless unit = Unit.invisible.find_by_name("contact")
        unit = create_unit
      end
      item = Item.new(:name => name, :unit_id => unit.id)
      item.visible = false
      self.item = item
    elsif self.changes[:name]
      self.item.name = name
    end
  end

  # Creates a new contact unit
  def create_unit
    unit = Unit.new(:name => 'contact', :symbol => "__ct" )
    unit.visible = false
    unit.save!
    unit
  end

  def self.all
    Contact.where( :organisation_id => OrganisationSession.id )
  end

end
