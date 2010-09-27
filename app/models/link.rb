class Link < ActiveRecord::Base

  belongs_to :organisation
  belongs_to :user

  attr_protected :user_id

  # We now can define the levels of access in this case 
  # we can define ["admin", "revisor", "user"]
  validates_presence_of :role
  validates_associated :user
  validates_associated :organisation

  scope :orgs, where(:user_id => UserSession.user_id)

  # Sets the current user and other attributes
  def set_user_creator_role(user_key)
    # raise NoMethodError, "No method \"current_user\" exists you must login to set it" if current_user.nil?
    # set_creator_role if id.nil?
    write_attribute(:user_id, user_key)
    write_attribute(:creator, true)
    write_attribute(:role, "admin")
  end

  
end
