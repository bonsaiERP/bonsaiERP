# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class TransactionHistory < ActiveRecord::Base
  #set_inheritance_column :sti_type

  # Relationships
  belongs_to :transaction
  belongs_to :user

  serialize :data

  def get_transaction(type)
    h = data
    hd = h.delete(:transaction_details)
    hd.map {|v| v.delete(:id) }
    h[:transaction_details_attributes] = hd

    if type == "Income"
      trans = Income.new(h)
    else
      trans = Buy.new(h)
    end

    [:balance, :total, :state, :gross_total, :tax_percent].each do |met|
      trans.send(:"#{met}=", data[met])
    end
    
    trans.taxis_ids = data[:taxis_ids]
    trans.payment_date = data[:payment_date]
    trans.original_total = data[:original_total]
      
    trans
  end
end
