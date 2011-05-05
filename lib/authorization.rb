# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# module to handle all authorization task
module Authorization

  protected
  # general method to check authorization
  def check_authorization!
    if current_user and session[:user][:rol]
      unless check_user_by_rol(session[:user][:rol], params[:controller], params[:action])
        flash[:warning] = "Usted no tiene permitida esta acción"
        redirect_to current_user
      end
    else
      redirect_to "/users/sign_in"
    end
  end

  # returns true or false depending
  def check_user_by_rol(rol, controller, action)
    return false unless User::ROLES.include?(rol)
    check_authorization(rol, controller, action)
  end

  def check_authorization(rol, controller, action)
    h = send(:"#{rol}_hash")
    if h[controller].nil?
      true
    else
      if h[controller][action].nil?
        true
      else
        h[controller][action]
      end
    end
  end

  #Hashes of priviledges
  def admin_hash
    {}
  end

  def gerency_hash
    admin_hash.merge(
      'users' => {'add_user'=> false, 'create_user' => false, 'edit_user' => false, 'update_user' => false},
      'taxes' => {'index' => false, 'show' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false}
    )
  end

  def inventory_hash
    gerency_hash.merge(
      'banks' => {'index' => false, 'show' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'cash_registers' => {'index' => false, 'show' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'account_ledgers' => {'index' => false, 'show' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false,
                          'new_transference' => false, 'transference' => false, 'conciliate' => false},
      'inventory_operations' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 
                  'select_store' => true, 'new_sale' => true, 'create_sale' => true},
      'incomes' => {'approve' => false},
      'buys' => {'approve' => false},
      'expenses' => {'approve' => false},
      'projects' => {'index' => true, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 'show' => true},
    )
  end

  def sales_hash
    inventory_hash.merge(
      'incomes' => {'approve' => true},
      'stores' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'inventory_operations' => {'index' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 
                  'select_store' => false, 'new_sale' => false, 'create_sale' => false},
      'items' => {'index' => true, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 'show' => true},
    )
  end
end
