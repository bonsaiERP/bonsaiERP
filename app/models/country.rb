# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Country < ActiveRecord::Base

  has_many :organisations

  validates_presence_of :name, :abbreviation

  serialize :taxes

  def to_s
    name
  end
end
