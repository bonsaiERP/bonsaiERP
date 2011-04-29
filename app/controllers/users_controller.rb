# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class UsersController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :authenticate_user!

  def new
    @user = User.new
    respond_with(@user)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Le hemos enviado un email para confirmar a: #{@user.email}"
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
    @user = User.new
  end

  # POST /users/create_user
  def create_user
    @user = User.new(params[:user])
    
    @user.generate_random_password
    @user.change_default_password = true
    
    if @user.save
      flash[:notice] = "El usuario #{@user.email} ha sido adicionado"
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

    if @user.update_attributes(params[:user])
      redirect_to current_user
    else
      render :action => 'edit'
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
      sign_in(@user, :bypass => true)
      redirect_to "/users/#{@user.id}", :notice => "Su contraseña a sido actualizada."
    else
      render :action => 'password'
    end
  end
end
