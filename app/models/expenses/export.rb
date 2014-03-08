class Expenses::Export < Movements::Export
  def export(col_sep: ",")
    super Expense, col_sep
  end

  private

    def movement_name
      'Egreso'
    end
end

