class Currency < ActiveRecord::Base
  include UUIDHelper

  has_many :organisations
  validates_presence_of :name, :symbol

  def to_s
    %Q(#{name} #{symbol})
  end
end
