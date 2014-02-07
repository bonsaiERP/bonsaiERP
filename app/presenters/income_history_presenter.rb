class IncomeHistoryPresenter < MovementHistoryPresenter
  def movement
    'Ingreso'
  end

  def details
    income_details
  end

  def details_col
    :income_details
  end

  def inventory_operation
    get_inventory_operation  if inventory_operation?
  end

  def inventory_operation?
    ['inventory_in', 'inventory_out'].include? operation_type
  end

  def get_inventory_operation
    if operation_type == 'inventory_out'
      context.text_green "Entrega de inventario <strong>#{inventory_operation_complete}</strong>"
    else
      context.text_red 'Devolución de inventario'
    end
  end

  def inventory_operation_complete
    mov_extras['to']['delivered'].to_s == 'true' ? 'completo' : 'parcial'
  end
end
