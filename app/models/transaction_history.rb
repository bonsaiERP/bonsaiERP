# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionHistory < ActiveRecord::Base
  attr_reader :hash, :klass

  # Relationships
  belongs_to :income, foreign_key: :account_id, conditions: {type: 'Income'}
  belongs_to :expense, foreign_key: :account_id, conditions: {type: 'Expense'}
  belongs_to :user

  serialize :data

  def self.create_history(trans)
    trans_hist = new(account_id: trans.id)
    trans_hist.data = trans_hist.get_transaction_data(trans)
    trans_hist.save!
    trans_hist
  end

  def get_transaction_data(trans)
    @klass = trans
    @hash = {}
    transaction_data
  end
private
  def transaction_data
    @hash = klass.attributes.symbolize_keys.slice!(:error_messages)
    h = klass.transaction_attributes.symbolize_keys.slice!(:created_at, :updated_at)
    @hash.merge!(h)
    transaction_details
    @hash
  end

  def transaction_details
    det = klass.is_a?(Income) ? :income_details : :expense_details
    @hash[det] = []
    klass.send(det).each do |d|
      @hash[det] << d.attributes.symbolize_keys.slice!(:created_at, :updated_at)
    end
  end
end
