# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Store < ActiveRecord::Base
  acts_as_org


  validates_presence_of :name, :address
end
