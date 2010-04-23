class Country < ActiveRecord::Base
  include UUIDHelper

  has_many :organisations

  validates_presence_of :name, :abbreviation

  serialize :taxes

  def to_s
    name
  end
end
