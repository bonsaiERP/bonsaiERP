# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class Transaction < ActiveRecord::Base
  ########################################
  # Relationships
  belongs_to :income, -> { where(type: 'Income') }, foreign_key: :account_id
  belongs_to :expense, -> { where(type: 'Expense') }, foreign_key: :account_id
  # Users
  belongs_to :creator, class_name: 'User'
  belongs_to :approver, class_name: 'User'
  belongs_to :nuller, class_name: 'User'

  validates_lengths_from_database

  def self.get_columns
    column_names.reject {|k| %w(id account_id created_at updated_at).include? k }.map(&:to_sym)
  end

  def self.delegate_methods
    [:discounted?, :delivered?, :devolution?,
    :creator, :approver, :nuller, :no_inventory?] +
    get_columns.map { |k| :"#{k}_was" }
  end
end
