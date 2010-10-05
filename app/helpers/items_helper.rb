# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
module ItemsHelper

  # Helper for links in items
  def link_new_item
    case @ctype
    when Item::TYPES[0]
      link_to "Nuevo item", new_item_path(:ctype => @ctype), :class => 'new'
    when Item::TYPES[1]
      link_to "Nuevo item de gasto", new_item_path(:ctype => @ctype), :class => 'new'
    when Item::TYPES[2]
      link_to "Nuevo producto", new_item_path(:ctype => @ctype), :class => 'new'
    when Item::TYPES[3]
      link_to "Nuevo servicio", new_item_path(:ctype => @ctype), :class => 'new'
    end
  end

  # Helper to present title
  def item_title
    case @ctype
    when Item::TYPES[0]
      "Items"
    when Item::TYPES[1]
      "Items de gasto"
    when Item::TYPES[2]
      "Productos"
    when Item::TYPES[3]
      "Servicios"
    end
  end

  # Helper to present title
  def item_type
    case @ctype
    when Item::TYPES[0]
      "item"
    when Item::TYPES[1]
      "item de gasto"
    when Item::TYPES[2]
      "producto"
    when Item::TYPES[3]
      "servicio"
    end
  end
end
