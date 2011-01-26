# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base
  acts_as_org

  # relationships
  belongs_to :transaction
  belongs_to :item

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )

  def total
    price * quantity
  end

  def after_initialize
    self.price ||= 0
    self.quantity ||= 0
  end

end
