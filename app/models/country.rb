class Country < ActiveRecord::Base
  has_many :organisations

  validates_presence_of :name, :abreviation

  def to_s
    name
  end
end
