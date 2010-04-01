class User < ActiveRecord::Base
  # devise
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  # Relationships
  has_many :links
  has_many :organisations, :through => :links

  # Validations
  validates_presence_of :first_name, :last_name

  # attr
  attr_protected :account_type


  def to_s
    %Q(#{first_name} #{last_name})
  end

end
