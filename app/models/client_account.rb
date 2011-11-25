# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ClientAccount < ActiveRecord::Base
  has_many :organisations

  def default
  end
end
