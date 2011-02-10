# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionDetail < ActiveRecord::Base
  acts_as_org
  # callbacks
  after_initialize :set_defaults

  # relationships
  belongs_to :transaction
  belongs_to :item

  # validations
  validates_presence_of :item_id
  validates_numericality_of :quantity, :greater_than => 0

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id )

  def total
    price * quantity
  end

private
  def set_defaults
    self.price ||= 0
    self.quantity ||= 0
  end

end
