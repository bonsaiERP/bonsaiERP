# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Contact < ActiveRecord::Base
  acts_as_org

  TYPES = ['clients', 'suppliers']

  # callbacks
  #before_save :change_nl2br#, :unless => lambda { |c| c.address.blank? }

  # relations
  has_many :transactions

  validates_presence_of   :name, :matchcode, :address
  validates_uniqueness_of :matchcode, :scope => :organisation_id
  validates_format_of     :email, :with => User.email_regexp, :allow_blank => true
  validates_format_of     :phone, :with =>/^\d+[\d\s-]+\d$/, :allow_blank => true
  validates_format_of     :mobile, :with =>/^\d+[\d\s-]+\d$/, :allow_blank => true


  attr_accessible :name, :matchcode, :organisation_name, :address, :addres_alt, :phone, :mobile, :email, :tax_number, :aditional_info
  
  # scopes
  scope :clients, where(:client => true)
  scope :suppliers, where(:supplier => true)

  def self.get_type(params = {})
    if TYPES.include?(params[:type])
      params[:type]     
    else
      false
    end
  end

  def to_s
    matchcode
  end

end
