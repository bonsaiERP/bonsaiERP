# encoding: utf-8
class MovementParams
  attr_reader :params

  def quick
    [:account_to_id, :contact_id, :amount, :date, :reference]
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
      :description, :due_date, :total,
      :direct_payment, :account_to_id, :reference, :tax_id, :tax_in_out, tag_ids: []
    ]
  end
end
