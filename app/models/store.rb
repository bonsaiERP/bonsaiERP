# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Store < ActiveRecord::Base
  acts_as_org

  has_many :stocks, :conditions => {:state => 'active'}
  has_many :inventory_operations

  validates_presence_of :name, :address

  def to_s
    name
  end
end
