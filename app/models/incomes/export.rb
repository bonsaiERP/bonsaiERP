class Incomes::Export < ExportTransactions
  def export(col_sep: ",")
    super IncomeQuery.new, col_sep
  end

private
  def trans_name
    'Ingreso'
  end
end
