# encoding: utf-8
class TransactionParams
  attr_reader :params

  def quick
    [:date, :ref_number, :fact, :bill_number, :amount, :contact_id, :account_id]
  end

  def quick_income
    quick
  end

  def income
    default
  end

  def default
    [:ref_number, :date, :contact_id, :currency_id, :exchange_rate, :project_id, :bill_number, :description, 
      :total, transaction_details_attributes: [
        :id, :item_id, :price, :quantity, :_destroy
      ]
    ]
  end
end
