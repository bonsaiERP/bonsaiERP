# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionHistory < ActiveRecord::Base

  # hash is a reserved word
  serialize :data, JSON

  # Relationships
  belongs_to :income, foreign_key: :account_id#, conditions: {type: 'Income'}
  belongs_to :expense, foreign_key: :account_id#, conditions: {type: 'Expense'}
  belongs_to :user

  validates_presence_of :user_id

  def create_history(trans)
    self.account_id = trans.id
    self.user_id = UserSession.id
    @klass = trans
    @hash = {}
    self.data = get_transaction_data

    self.save
  end

private
  def get_transaction_data
    @hash = @klass.attributes.symbolize_keys.slice!("error_messages")
    h = @klass.transaction_attributes.symbolize_keys.slice!("id", "created_at", "updated_at")
    @hash.merge!(h)
    transaction_details
    @hash
  end

  def transaction_details
    det = @klass.is_a?(Income) ? :income_details : :expense_details
    @hash[det] = []
    @klass.send(det).each do |d|
      @hash[det] << d.attributes.symbolize_keys.slice!("created_at", "updated_at")
    end
  end
end
