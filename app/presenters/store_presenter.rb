# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class StorePresenter < BasePresenter
  def address_tag
    "#{ icon 'icon-building muted', 'Dirección' } #{sanitize address}".html_safe  if address.present?
  end

  def phone_tag
    "#{ icon 'icon-phone muted', 'Teléfono' } #{sanitize phone}".html_safe  if phone.present?
  end

  def items(attrs = {})
    if attrs[:search_items].present?
      st = stocks.item_like(attrs[:search_items])
    else
      st = stocks
    end
    st = st.mins  if attrs[:minimum_inventory].present?

    st.includes(:item).page(page attrs[:page_items]).order('items.name')
  end

  def inventories(attrs = {})
    inv = Inventory.includes(:creator, :income, :expense)
    .where("store_id=:id OR store_to_id=:id", id: id)

    if attrs[:search_operations].present?
      s = "%#{ attrs[:search_operations] }%"
      inv = inv.where{ ref_number.like s }
    elsif valid_date_range?(attrs)
      inv = inv.where(date: date_range(attrs).range)
    end

    inv.page(page attrs[:page_operations]).order("date desc, id desc")
  end

  private

    def date_range(attrs)
      DateRange.parse(attrs[:date_start], attrs[:date_end])
    end

    def valid_date_range?(attrs = {})
      attrs[:date_start].present? && attrs[:date_end].present?
    end

    def page(val)
      is_valid_page?(val) ? val : 1
    end

    def is_valid_page?(val)
      val.present? && val.to_i > 0
    end

end
