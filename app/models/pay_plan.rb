# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class PayPlan < ActiveRecord::Base
  acts_as_org
  STATES = ["valid", "delayed", "payed"]

  # relationships
  belongs_to :transaction

  # scopes
  default_scope where(:organisation_id => OrganisationSession.organisation_id)

  # Returns the current state of the payment
  def state
    if paid?
      "Pagado"
    elsif payment_date < Date.today
      "Atrasado"
    else
      "Valido"
    end
  end
end
