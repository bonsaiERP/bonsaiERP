class UserPresenter < BasePresenter
  delegate :active?, :role, to: :link, prefix: true

  def roles_hash
    Hash[User::ROLES.zip(roles_list)]
  end

  def role
    roles_hash[link_role]
  end

  def role_options
    roles_hash.map { |k, v| [v, k] }
  end

  def sliced_role_options
    role_options.slice(1, 3)
  end

  def master_account_tag
    icon('icon-star violet icon-large', 'Cuenta maestra')  if link.master_account?
  end

  def roles_list
    %w(Admin Superior Operaciones)
  end

  def activate_deactivate_link
    if link_active?
      link_to 'Desactivar', context.active_admin_user_path(id, active: false), class: 'btn btn-small btn-danger active', method: :patch, remote: true
    else
      link_to 'Activar', context.active_admin_user_path(id, active: true), class: 'btn btn-small btn-success active', method: :patch, remote: true
    end
  end

  # Returns the link with the organissation one is logged in
  def link
    @link ||= links.find_by_organisation_id(context.current_organisation.id)
  end

end
