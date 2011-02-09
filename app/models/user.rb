# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class User < ActiveRecord::Base
  # callbacks

  # devise
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  # Relationships
  has_many :links
  has_many :organisations, :through => :links

  # Validations

  #attr_protected :account_type
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name, :phone, :mobile, :website, :description


  def to_s
    %Q(#{first_name} #{last_name})
  end

  # Checks the user and the priviledges
  def check_organisation?(organisation_id)
    organisations.map(&:id).include?(organisation_id.to_i)
  end

end
