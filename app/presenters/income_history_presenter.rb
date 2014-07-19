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
      "Entrega de inventario #{inventory_operation_tag}"
    else
      context.text_red 'Devolución de inventario'
    end
  end

  def inventory_operation_tag
    if delivered?
      text_green 'completo', nil, 'b'
    else
      text_green 'parcial', nil
    end
  end

end
