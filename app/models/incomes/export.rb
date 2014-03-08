# Object used for exporting data
class Incomes::Export < Movements::Export
  def export(col_sep: ",")
    super Income, col_sep
  end

  private

    def movement_name
      'Ingreso'
    end
end
