class Organisation < ActiveRecord::Base
  # callbacks

  # relationships
  belongs_to :user
  belongs_to :country

  # validations
  validates_presence_of :user, :country, :name, :address, :phone
  validates_uniqueness_of :name, :scope => :user_id

  attr_protected :user_id
  
  def to_s
    %Q(name)
  end

  def set_user(current_user)
    user = current_user
  end

end
