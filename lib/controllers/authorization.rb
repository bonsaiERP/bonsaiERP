# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# module to handle all authorization task
module Controllers::Authorization

  protected
  # general method to check authorization
  def check_authorization!
    if current_user and session[:user] and session[:user][:rol]
      if session[:organisation].present?
        if not(request.path === "/dashboard") and session[:organisation][:due_date] + 5.days < Date.today
          flash[:warning] = "Su cuenta ha expirado, por favor realice el pago correspondiente."
          return redirect_to("/dashboard",)
        end
      end

      unless check_user_by_rol(session[:user][:rol], params[:controller], params[:action])
        redirect_to "/422"
      end
    elsif current_user and current_user.link.nil?
      true
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
    elsif h[controller] === false or h[controller] === true
      h[controller]
    else
      if h[controller] and h[controller][action].nil?
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
      'users' => {'add_user'=> false, 'create_user' => false, 'edit_user' => false, 'update_user' => false, 'edit' => false, 'update' => false},
      'taxes' => {'index' => false, 'show' => false, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false},
      'organisations' => false
    )
  end

  def operations_hash
    gerency_hash.merge(
      'banks' => false, 'cashes' => false, 'staffs' => false,
      'account_ledgers' => {
        'index' => false, 'show' => true, 'new' => false, 'new_transference' => false,
        'conciliate' => false, 'create' => false, 'destroy' => false, 
        'transference' => false, 'update' => false
      },
      'inventory_operations' => {'index' => true, 'show' => true, 'new' => false,
         'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 
         'select_store' => true, 'new_transaction' => true, 'create_transaction' => true},
      'incomes' => {'approve' => false},
      'buys' => false,
      'stores' => {'new' => false, 'edit' => false, 'update' => false, 'create' => false, 'destroy' => false},
      'payments' => {'destroy' => false},
      'projects' => {'index' => true, 'new' => false, 'create' => false, 'edit' => false, 'update' => false, 'destroy' => false, 'show' => true}
    )
  end

end
