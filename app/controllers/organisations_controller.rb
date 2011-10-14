# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_filter :check_authorization!
  before_filter :destroy_organisation_session!, :except => [ :select, :edit, :update, :edit_preferences, :update_preferences ]

  respond_to :html, :xml, :json
  # GET /organisations
  # GET /organisations.xml
  def index
    destroy_organisation_session!

    @organisations = current_user.organisations
    if current_user.organisations.any?
      set_organisation_session(current_user.organisations.first)
      @currency_rates = CurrencyRate.current_hash
      render "/dashboard/index"
    else
      reset_org
      session[:step] = params[:step] || 1
      session[:max_step] ||= 1

      send(:"get_step_#{session[:step]}")
      render :action => 'new'
    end
  end

  # GET /organisations/1
  # GET /organisations/1.xml
  def show
    @organisation = Organisation.find(params[:id])
    set_organisation_session(@organisation)
    respond_with(@organisation)
  end

  # GET /organisations/new
  def new
    @organisation = Organisation.new(:currency_id => 1)
  end

  # POST /organisations
  def create
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      flash[:notice] = "Se ha creado su empresa correctamente."
      params[:id] = @organisation.id

      if set_organisation_session(@organisation)
        redirect_to "/dashboard"
      else
        flash[:error] = "Por favor ingrese de nuevo existio un error en el sistema."
        redirect_to "/users/sign_out"
      end
    else
      render :action => 'new'
    end
  end

  # GET /organisations/1/edit
  def edit
    @organisation = Organisation.find(session[:organisation][:id])
    respond_with(@organisation)
  end

  # POST /organisations
  # POST /organisations.xml
  #def create

  #  if params[:step].present? and params[:step].to_i < 4
  #    send(:"create_step_#{params[:step]}")
  #  else
  #    get_step_1
  #  end
  #  
  #  render :action => 'new'
  #end

  # POST /organisations/final_step
  def final_step

    @organisation = Organisation.new(session[:org].attributes)
    @organisation.account_info = session[:account]

    if @organisation.save
      flash[:notice] = "Se ha creado su empresa correctamente."
      params[:id] = @organisation.id

      session[:account] = nil
      session[:org] = nil
      
      set_organisation_session(@organisation)

      redirect_to "/dashboard"
    else
      flash[:error] = @organisation.errors[:base].join(", ")
      redirect_to "/organisations/new?step=3"
    end

  end

  # PUT /organisations/1
  # PUT /organisations/1.xml
  def update
    @organisation = Organisation.find(session[:organisation][:id])
    if @organisation.update_attributes(params[:organisation])
      set_organisation_session @organisation
      flash[:notice] = "Se ha actualizado correctamente los datos de su empresa."

      redirect_to "/configuration#organisation"
    else
      render :action => 'edit'
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.xml
  #def destroy
  #  @organisation = Organisation.find(params[:id])
  #  @organisation.destroy

  #  respond_with(@organisation)
  #end

  # GET /organisation/1/select
  # sets the organisation session
  def select
    begin
      @organisation = current_user.organisations.find(params[:id])
    rescue
      @organisation = nil
    end

    unless @organisation.blank?
      set_organisation_session(@organisation)
      redirect_to dashboard_url
    else
      flash[:error] = "Debe seleccionar una organización válida."
      redirect_to organisations_path
    end
  end

  # set preferences
  # GET /organisations/:id/edit_preferences
  def edit_preferences
    @organisation = Organisation.find(organisation_id)
  end

  # GET /organisations/:id/update_preferences
  def update_preferences
    @organisation = Organisation.find(organisation_id)
    if @organisation.update_preferences(params[:organisation])
      flash[:notice] = "Se ha actualizado correctamente las preferencias de #{@organisation}."
      set_organisation_session(@organisation)

      redirect_to "/configuration#organisation"
    else
      render :action => 'edit_preferences'
    end
  end

end
