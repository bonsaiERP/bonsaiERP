# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AdminUsersController < ApplicationController
  rescue_from MasterAccountError, with: :redirect_to_conf
  before_action :check_organisation_users, except: [:active]

  # GET /admin_users/:id
  def show
    @user = get_user
  end

  # GET /admin_users/new
  def new
    @admin_user = AdminUser.new
  end

  # POST /admin_users
  def create
    @admin_user = AdminUser.new(create_params)
    if @admin_user.create
      redirect_to configurations_path,  notice: 'El usuario ha sido adicionado.'
    else
      render :new
    end
  end

  # GET /admin_users/:id/edit
  def edit
    @admin_user = AdminUser.find(current_organisation, params[:id])
  end

  # PATCH /admin_users/:id
  def update
    @admin_user = AdminUser.find(current_organisation, params[:id])

    if @admin_user.update(update_params)
      redirect_to configurations_path, notice: 'El usuario ha sido actualizado'
    else
      render :edit
    end
  end

  # Activates or deactivates a user in a organisation
  # PATCH /admin_users/:id/active
  def active
    u_role = UserWithRole.new(User.find(params[:id]), current_organisation)

    if params[:active] == 'true' and valid_organisation_users?
      u_role.link.update_attribute(:active, true)
    else
      u_role.link.update_attribute(:active, false)
    end

    @user = u_role.user

    render 'active.js'
  end

  # DELETE
  def destroy
    user = current_organisation.users.find(params[:id])

    unless user.last_sign_in_at?
      user.destroy
      flash[:notice] = 'El usuario fue eliminado.'
    else
      flash[:error] = 'No es posible borrar el usuario, desactive el usuario si desea que no ingrese a su sistema.'
    end

    redirect_to configurations_path
  end

  private

    def create_params
      params.require(:admin_user)
      .permit(:email, :first_name, :last_name, :role)
      .merge(organisation: current_organisation)
    end

    def update_params
      create_params.except(:email, :first_name, :last_name)
    end

    def check_master_account
      raise MasterAccountError  unless user_with_role.master_account?
    end

    def redirect_to_conf
      flash[:alert] = 'La cuenta maestra no puede ser editada'
      redirect_to configurations_path
    end

    def valid_organisation_users?
      current_organisation.plan.to_i > current_organisation.active_users.count
    end

    def check_organisation_users
      if current_organisation.plan.to_i <= current_organisation.active_users.count
        flash[:alert] = 'Ya ha llegado al limite de usuarios para su plan, contactese con contacto@bonsaierp.com para actualizar su plan.'
        redirect_to '/configurations' and return
      end
    end
end
