module ContactsHelper
  # Sets the contact type
  def contact_type(type, plural = true)
    if type == 'clients'
      plural ? 'Clientes' : 'cliente'
    elsif type == "suppliers"
      plural ? 'Proveedores' : 'proveedor'
    end
  end
end
