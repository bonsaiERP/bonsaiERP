# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AccountBalance < ActiveRecord::Base
  before_create :update_contact_account

  belongs_to :user
  belongs_to :account
  belongs_to :contact
  belongs_to :currency

  validates_numericality_of :amount
  validates_presence_of :currency
  validates_presence_of :contact
  validates_presence_of :currency_id

  private
  def update_contact_account
    self.user_id = UserSession.user_id
    ac = contact.account_cur(currency_id)
    if ac
      self.old_amount = ac.amount
      self.account_id = ac.id
      ac.update_attribute(:amount, self.amount)
    else
      self.old_amount = 0
      ac = contact.accounts.build(
        :currency_id => currency_id,
        :account_type_id => AccountType.find_by_account_number(contact.class.to_s).id
      ) {|a|
        a.original_type = contact.class.to_s
        a.name = contact.to_s
        a.amount = amount
        a.initial_amount = amount
      }

      ac.save!

      self.account_id = ac.id

    end
  end
end
