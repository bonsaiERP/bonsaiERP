# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Stock < ActiveRecord::Base
  acts_as_org

  STATES = ["active", "inactive", "waiting"]

  belongs_to :store
  belongs_to :item
end
