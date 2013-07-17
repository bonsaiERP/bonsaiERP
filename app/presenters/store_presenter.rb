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

  def items(attrs = {})
    if attrs[:search_items].present?
      st = stocks.item_like(attrs[:search_items])
    else
      st = stocks.includes(:item)
    end
    st = st.mins  if attrs[:minimum_inventory].present?

    st.page(page attrs[:page_items]).order('items.name')
  end

  def inventories(page = 1)
    to_model.inventories.includes(:creator).page(page).order("date desc")
  end

private

  def page(val)
    is_valid_page?(val) ? val : 1
  end

  def is_valid_page?(val)
    val.present? && val.to_i > 0
  end

end
