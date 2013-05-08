class ExportExpenses < ExportTransactions
  def export(col_sep: ",")
    super ExpenseQuery.new, col_sep
  end

private
  def trans_name
    'Egreso'
  end
end

