class UserPresenter < BasePresenter

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

  def roles_list
    %w(Gerencia Administración Operaciones)
  end
end
