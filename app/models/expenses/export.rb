class Expenses::Export < Movements::Export
  def export(col_sep: ",")
    super Expenses::Query.new, col_sep
  end

private
  def trans_name
    'Egreso'
  end
end

