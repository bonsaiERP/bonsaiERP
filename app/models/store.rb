# encoding: utf-8
class Store < ActiveRecord::Base
  acts_as_org


  validates_presence_of :name, :address
end
