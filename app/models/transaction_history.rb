# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionHistory < ActiveRecord::Base
  #set_inheritance_column :sti_type

  # Relationships
  belongs_to :transaction

  serialize :data
end
