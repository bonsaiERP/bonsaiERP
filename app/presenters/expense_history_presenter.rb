class ExpenseHistoryPresenter < MovementHistoryPresenter
  def movement
    'Egreso'
  end

  def details
    expense_details
  end

  def details_col
    :expense_details
  end

  def inventory_operation
    get_inventory_operation  if inventory_operation?
  end

  def inventory_operation?
    ['inventory_in', 'inventory_out'].include? operation_type
  end

  def get_inventory_operation
    if operation_type == 'inventory_in'
      context.text_green "Recepción de inventario <strong>#{inventory_operation_complete}</strong>"
    else
      context.text_red 'Devolución de inventario'
    end
  end

  def inventory_operation_complete
    mov_extras['to']['delivered'].to_s == 'true' ? 'completo' : 'parcial'
  end
end

