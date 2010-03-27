class Organisation < ActiveRecord::Base
  # callbacks

  # relationships
  belongs_to :user
  belongs_to :country

  # validations
  validates_associated :user
  validates_associated :country

  validates_presence_of :name, :address, :phone, :user_id, :country_id
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id
  
  def to_s
    %Q(name)
  end

  def set_user(current_user_id)
    write_attribute(:user_id, current_user_id)
  end

end
