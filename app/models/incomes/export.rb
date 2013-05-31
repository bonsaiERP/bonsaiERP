class Incomes::Export < Movements::Export
  def export(col_sep: ",")
    super Incomes::Query.new, col_sep
  end

private
  def trans_name
    'Ingreso'
  end
end
