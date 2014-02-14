# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class AdminUsersController < ApplicationController
  before_action :check_master_account, only: [:edit, :update, :active]

  rescue_from MasterAccountError, with: :redirect_to_conf

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
    @user = current_organisation.users.find(params[:id])
    @link = @user.links.where(organisation_id: current_organisation.id).first!

    @link.update_attribute(:active, params[:active])
  end

  private

    def create_params
      params.require(:admin_user)
      .permit(:email, :first_name, :last_name, :phone,:mobile, :address, :link_role)
    end

    def update_params
      create_params.except(:email)
    end

    def check_master_account
      raise MasterAccountError  if user_with_role.master_account?
    end

    def redirect_to_conf
      flash[:alert] = 'La cuenta maestra no puede ser editada'
      redirect_to configurations_path
    end
end
