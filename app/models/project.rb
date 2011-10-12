# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Project < ActiveRecord::Base
  acts_as_org

  attr_accessible :name, :active, :date_start, :date_end, :description

  # associations
  has_many :transactions

  # validations
  validates_presence_of :name

  def to_s
    name
  end
end
