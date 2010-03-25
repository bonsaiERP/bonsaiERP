class User < ActiveRecord::Base
  devise :authenticatable, :confirmable, :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :first_name, :last_name

  def to_s
    %Q(#{first_name} #{last_name})
  end
end
