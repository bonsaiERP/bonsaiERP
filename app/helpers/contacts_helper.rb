module ContactsHelper
  def contact_type(type)
    if type == 'clients'
      'Clientes'
    elsif type == "suppliers"
      'Proveedores'
    else
      'Todos los contactos'
    end
  end
end
