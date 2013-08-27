# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
# module to handle all authorization task
module Controllers::Authorization

private
  # general method to check authorization
  def check_authorization!
    check_current_user!
    return false unless current_user

    # TODO check due_date
    unless authorized_user?
      flash[:alert] = "Usted ha sido redireccionado por que no tiene suficientes privilegios."
      redir = request.referer.present? ? :back : dashboard_path

      redirect_to redir and return
    end
  end

  def check_current_user!
    unless current_user.present?
      flash[:alert] = "Por favor ingrese."
      redirect_to new_session_url(subdomain: false) and return
    end
  end

  # Checks the white list for controllers
  def authorized_user?
    rol = current_user.link_rol
    unless rol
      request.env["HTTP_REFERER"] = logout_path
      return false
    end

    h = send(:"#{rol}_hash")

    if h[controller_sym].is_a?(Hash)
      h[controller_sym][action_sym]
    else
      !!h[controller_sym]
    end
  end

  def controller_sym
    controller_name.to_sym
  end

  def action_sym
    action_name.to_sym
  end

  #Hashes of priviledges
  def admin_hash
    {
      organisation_updates: true,
      admin_users: true,
      configurations: true,
      tests: true,
      stocks: true,
      inventories: true,
      account_ledgers: true,
      banks: true,
      cashes: true,
      transferences: true,
      devolution: true,
      payments: true,
      devolutions: true,
      projects: true,
      incomes: true,
      expenses: true,
      stores: true,
      contacts: true,
      staffs: true,
      items: true,
      units: true,
      users: true,
      user_passwords: true,
      dashboard: true,
      export_incomes: true,
      export_expenses: true,
      inventory_ins: true,
      inventory_outs: true,
      incomes_inventory_ins: true,
      incomes_inventory_outs: true,
      expenses_inventory_ins: true,
      expenses_inventory_outs: true,
      tags: true,
      reports: true,
      inventory_transferences: true,
      download: true
    }
  end

  def group_hash
    {
      admin_users: {show: true},
      configurations: {index: true},
      tests: false,
      stocks: true,
      inventories: true,
      account_ledgers: true,
      banks: true,
      cashes: true,
      transferences: true,
      devolution: true,
      payments: true,
      devolutions: true,
      projects: true,
      incomes: true,
      expenses: true,
      stores: true,
      contacts: true,
      staffs: false,
      items: true,
      units: true,
      users: true,
      user_passwords: true,
      dashboard: true,
      export_incomes: true,
      export_expenses: true,
      inventory_ins: true,
      inventory_outs: true,
      incomes_inventory_ins: true,
      incomes_inventory_outs: true,
      expenses_inventory_ins: true,
      expenses_inventory_outs: true,
      tags: true,
      reports: true,
      inventory_transferences: true,
      download: true
    }
  end

  def other_hash
    {
      admin_users: false,
      configurations: false,
      tests: false,
      stocks: true,
      inventory_operations: false,
      account_ledgers: {show: true},
      banks: false,
      cashes: false,
      devolution: false,
      payments: true,
      projects: false,
      incomes: true,
      expenses: true,
      stores: false,
      contacts: true,
      staffs: false,
      items: true,
      units: true,
      users: true,
      user_passwords: true,
      dashboard: true,
      incomes_inventory_outs: true,
      tags: true,
      download: true
    }
  end

end
