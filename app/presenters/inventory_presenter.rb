# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class InventoryPresenter < BasePresenter

  def link
    case
    when(is_income? || is_expense?)
      "/inventories/#{id}/show_movement"
    when is_trans?
      "/inventories/#{id}/show_trans"
    else
      to_model
    end
  end

  def operation_tag
    case operation
    when 'in' then text_green(operation_name)
    when 'out' then text_red(operation_name)
    when 'inc_out' then text_green(operation_name)
    when 'inc_in' then text_red(operation_name)
    when 'exp_in' then text_green(operation_name)
    when 'exp_out' then text_red(operation_name)
    when 'trans' then text_gray(operation_name)
    end
  end

  def operation_name
    case operation
    when 'in' then 'Ingreso inventario'
    when 'out' then 'Egreso inventario'
    when 'inc_out' then 'Entrega'
    when 'inc_in' then 'Devolución'
    when 'exp_in' then 'Recepción'
    when 'exp_out' then 'Devolución'
    when 'trans' then 'Transferencia'
    end
  end

  def select_store_title
    case
    when (transaction.is_a?(Income) and inventory_operation.out?)
      "<span class='dark_green'>Entrega</span>".html_safe
    when (transaction.is_a?(Income) and inventory_operation.in?)
      "<span class='red'>Devolución</span>".html_safe
    when (transaction.is_a?(Buy) and inventory_operation.in?)
      "<span class='dark_green'>Recojo</span>".html_safe
    when (transaction.is_a?(Buy) and inventory_operation.out?)
      "<span class='red'>Devolución</span>".html_safe
    end
  end

  def related(st_id = nil)
    case
    when is_income?  then income
    when is_expense? then expense
    when(is_trans? && st_id.present?)
      store_id === st_id ? store_to : store
    when(is_trans? && st_id.nil?)
      store_to
    else
      nil
    end
  end

  def has_related?
    is_income? || is_expense? || is_trans?
  end

  def related_tip(st_id = nil)
    case
    when is_income?
      I18n.t('presenters.inventory.related_tip.income')
    when is_expense?
      I18n.t('presenters.inventory.related_tip.expense')
    when(is_trans? && st_id == store_id && st_id.present?)
      I18n.t('presenters.inventory.related_tip.store_destiny')
    when(is_trans? && st_id != store_id && st_id.present?)
      I18n.t('presenters.inventory.related_tip.store_source')
    when(is_trans? && st_id.nil?)
      "Almacen destino"
    end
  end

  def transaction_title
    "#{select_store_title} #{sanitize transaction}".html_safe
  end

  def title
    store = h.link_to inventory_operation.store, store_path(inventory_operation.store_id, tab: 'operations'), class: 'n'

    case
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.out? )
      "<span class='gray n'>Entrega</span> #{store} - #{sanitize transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.in? )
      "<span class='gray n'>Devolución</span> #{store} - #{sanitize transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Buy) && inventory_operation.in? )
      "<span class='gray n'>Recojo</span> #{sanitize transaction}".html_safe
    when( inventory_operation.transaction_id.present? && transaction.is_a?(Income) && inventory_operation.out? )
      "<span class='gray n'>Devolución</span> #{sanitize store} - #{sanitize transaction}".html_safe
    when inventory_operation.in?
      "<span class='gray n'>Ingreso</span> #{sanitize store}".html_safe
    when inventory_operation.out?
      "<span class='gray n'>Egreso</span>  #{sanitize store}".html_safe
    when inventory_operation.transout? || inventory_operation.transin?
      "<span class='gray n'>Transferencia</span> #{sanitize store} - #{inventory_operation.ref_number}".html_safe
    end
  end

  def link_related
    if inventory_operation.transference_id.present?
      trans = inventory_operation.transference
      txt = inventory_operation.operation == "transout" ? "a" : "desde"
      h.link_to "Transferencia #{txt} #{inventory_operation.store_to}", trans, title: "Transferencia a #{inventory_operation.store_to}"
    elsif inventory_operation.contact_id.present?
      cont = inventory_operation.contact
      h.link_to cont, cont, title: contact_tooltip
    end
  end

  def transaction_tooltip
    if inventory_operation.transaction.is_a?(Income)
      'Venta'
    else
      'Compra'
    end
  end

  def contact_tooltip
    if inventory_operation.contact.is_a?(Client)
      I18n.t('presenters.inventory.contact_tooltip.client')
    else
      I18n.t('presenters.inventory.contact_tooltip.supplier')
    end
  end
end
