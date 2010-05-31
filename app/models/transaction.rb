# encoding: utf-8
class Transaction < ActiveRecord::Base
  include UUIDHelper
  acts_as_org
end
