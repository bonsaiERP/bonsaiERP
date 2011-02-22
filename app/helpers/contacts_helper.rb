module ContactsHelper
  def contact_type(type)
    if type == 'clients'
      'Clientes'
    else
      'Proveedores'
    end
  end
end
