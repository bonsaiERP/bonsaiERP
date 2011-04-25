# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Link < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :user

  has_many :organisations

  attr_protected :user_id, :creator

  # rol_id needs to be asgined with the Rol model
  #validates_presence_of :rol_id
  validates_associated :user
  validates_associated :organisation

  # scope :orgs, where(:user_id => UserSession.current_user.try(:id) )

  # Sets the current user and other attributes
  def set_user_creator(user_key)
    # raise NoMethodError, "No method \"current_user\" exists you must login to set it" if current_user.nil?
    write_attribute(:user_id, user_key)
    write_attribute(:creator, true)
    # Needs to be updated to use the Rol model
    # self.rol_id = 1
    # write_attribute(:rol_id, 1)
  end

  
end
