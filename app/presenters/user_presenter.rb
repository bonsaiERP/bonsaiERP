# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UserPresenter < BasePresenter
  presents :user

  def edit_link
    if h.session[:user][:rol] === "admin" and h.current_user.id == user.id
      h.link_to "Editar datos", edit_user_path(@user), :class => 'edit'
    end
  end

  def password_link
    if h.session[:user_id] === user.id
      h.link_to "Cambiar contraseña", password_users_path, :class => 'key'
    end
  end
end
