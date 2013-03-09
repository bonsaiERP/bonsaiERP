# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Project < ActiveRecord::Base

  # associations
  has_many :transactions
  has_many :account_ledgers

  # validations
  validates_presence_of :name

  scope :active, -> { where(active: true) }

  def to_s
    name
  end
end
