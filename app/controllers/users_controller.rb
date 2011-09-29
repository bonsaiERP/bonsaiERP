# encoding: utf-8 # author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :check_authorization!
  before_filter :check_if_default_password, :only => [:password, :update_password]

  def new
    @user = User.new
    respond_with(@user)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Le hemos enviado un email para confirmar a: #{@user.email}."
    else
      render :action => 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  # GET /users/add_user
  def add_user
    @user = User.new {|u| u.change_default_password = true}
  end

  # POST /users/create_user
  def create_user
    @user = User.new
    if @user.add_company_user(params[:user])
      flash[:notice] = "El usuario #{@user} ha sido adicionado."
      redirect_to "/configuration"
    else
      render :action => 'add_user'
    end
  end

  # GET /users/:id/edit
  def edit
  end

  # PUT /users/:id/update_user
  def update
    @user = current_user
    h = params[:user]
    h.delete(:password)

    if @user.update_attributes(h)
      redirect_to current_user, :notice => "Se ha actualizado correctamente sus datos."
    else
      render :action => 'edit'
    end
  end

  # Method for the admins that control an organisation
  # GET /users/:id/edit_user
  def edit_user
    @user = current_user.organisation.links.find_by_user_id(params[:id]).user
    check_if_creator(@user)
    @user.rolname = @user.link.rol
    @user.active_link = @user.link.active
  end

  # Method for the admins that control an organisation
  # PUT /users/:id/update_user
  def update_user
    h = params[:user]
    h[:rolname] = '' if params[:user][:rolname] == 'admin'
    @user = current_user.organisation.links.find_by_user_id(params[:id]).user
    check_if_creator(@user)
    
    if @user.update_attributes(params[:user])
      flash[:notice] = "El usuario #{@user} ha sido actualizado."
      redirect_to "/configuration"
    else
      render :action => 'edit_user'
    end
  end

  # GET /users/default_password
  def default_password
    return redirect_to "/422" unless current_user.change_default_password?
    @user = current_user
  end

  # PUT /users/update_default_password
  def update_default_password
    return redirect_to "/422" unless current_user.change_default_password?

    if current_user.update_password(params[:user])
      redirect_to current_user
    else
      render "default_password"
    end
  end

  # /users/password
  def password
  end

  # PUT /users/:id/update_password
  def update_password
    @user = current_user
    p = params[:user]
    @user.change_default_password = false

    if @user.update_password(params[:user])
      redirect_to "/users/#{@user.id}", :notice => "Su contraseña a sido actualizada."
    else
      render :action => 'password'
    end
  end


  private
  def check_if_default_password
    redirect_to default_password_users_path if current_user.change_default_password?
  end

  def check_if_creator(user)
    if user.link.creator?
      flash[:warning] = "No es posible cambiar para el creador de la empresa, Haga <a href='/users/0/edit'>click aquí</a> si desea cambiar sus datos.".html_safe
      redirect_to "/configuration"
    end
  end
end
