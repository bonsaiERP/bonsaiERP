# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StorePresenter < BasePresenter
  def address_tag
    "#{ icon 'icon-building', 'Dirección' } #{address}".html_safe if address.present?
  end

  def phone_tag
    "#{ icon 'icon-phone', 'Teléfono' } #{phone}".html_safe if phone.present?
  end

  def items
    stocks.includes(item: :unit).order('items.name')
  end

  def operations
    present inventories, InventoryPresenter
  end

  def inventories
    to_model.inventories.includes(:creator)
  end
end
