# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  acts_as_org

  TYPES = ['clients', 'suppliers', 'staff']

  # callbacks

  # relations
  has_many :transactions

  validates_presence_of   :first_name, :last_name, :address# :code
  #validates_uniqueness_of :code, :scope => :organisation_id
  validates_uniqueness_of :matchcode, :scope => :organisation_id

  validates_format_of     :email,  :with => User.email_regexp, :allow_blank => true
  validates_format_of     :phone,  :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true
  validates_format_of     :mobile, :with =>/^\d+[\d\s-]+\d$/,  :allow_blank => true

  attr_accessible :first_name, :last_name, :code, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info, :matchcode
  
  # scopes
  scope :clients, where(:client => true)
  scope :suppliers, where(:supplier => true)

  # Finds a contact using the type
  # @param String
  def self.find_with_type(type)
    type = 'all' unless TYPES.include?(type)
    case type
    when 'clients' then Contact.org.clients
    when 'suppliers' then Contact.org.suppliers
    when 'all' then Contact.org
    end
  end

  def to_s
    matchcode
  end

  def pdf_name
    "#{first_name} #{last_name}"
  end

private
  def set_matchcode
    self.matchcode = "#{code} #{first_name} #{last_name}"
  end

end
