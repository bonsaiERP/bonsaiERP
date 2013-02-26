# encoding: utf-8
class TransactionParams
  attr_reader :params

  def quick
    [:date, :fact, :bill_number, :amount, :contact_id, :account_id, :account_to_id, :verification]
  end

  def quick_income
    quick
  end

  def income
    default + [income_details_attributes: details]
  end

  def expense
    default + [expense_details_attributes: details]
  end

  def details
    [:id, :item_id, :price, :quantity, :_destroy]
  end

  def default
    [
      :date, :contact_id, :currency, :exchange_rate, :project_id, 
      :bill_number, :description, :due_date, :total
    ]
  end
end
