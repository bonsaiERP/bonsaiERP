class User < ActiveRecord::Base
  # callbacks


  # devise
  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  # Relationships
  has_many :links
  has_many :organisations, :through => :links

  # Validations

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, :description


  def to_s
    %Q(#{first_name} #{last_name})
  end

end
