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
    @organisation.set_default_preferences
  end

  # POST /organisations
  def create
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      flash[:notice] = "Se ha creado su empresa correctamente."
      params[:id] = @organisation.id

      ret = set_organisation_session(@organisation)
      if ret
        redirect_to "/dashboard"
      else
        flash[:error] = "Por favor ingrese de nuevo existio un error en el sistema"
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
      flash[:notice] = "Se ha actualizado correctamente los datos de su empresa"

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
      flash[:error] = "Debe seleccionar una organización válida"
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
      flash[:notice] = "Se ha actualizado correctamente las preferencias de #{@organisation}"
      set_organisation_session(@organisation)

      redirect_to "/configuration#organisation"
    else
      render :action => 'edit_preferences'
    end
  end
private
  def select_org()
    @organisation = current_user.links.first.organisation
    set_organisation_session(@organisation)
  end

  # resets the session org
  def reset_org
    session[:org]     = nil
    session[:account] = nil
  end
  # Steps for organisation creation
  def get_step_1
    @partial = "form"
    @local = :organisation
    @object = session[:org] || Organisation.new(:currency_id => 1)
  end

  def create_step_1
    @object = Organisation.new(params[:organisation])
    if @object.valid?
      session[:org]      = @object
      session[:step]     = 2
      session[:max_step] = 2 if session[:max_step] < 2
    
      session[:organisation] = {:id => 0, :name => @object.name, :currency_id => @object.currency_id}
      
      get_step_2
    else
      @partial = "form"
      @local = :organisation
    end
  end

  def get_step_2
    params[:account] ||= "Bank"
    params[:account] = "CashRegister" if session[:account].is_a?(CashRegister)

    case params[:account]
    when "Bank"         then @object = Bank.new(:currency_id => session[:org].currency_id)
    when "CashRegister" then @object = CashRegister.new(:currency_id => session[:org].currency_id)
    else
      @object = CashRegister.new(:currency_id => session[:org].currency_id)
    end

    @object = session[:account] if params[:account] == session[:account].class.to_s

    @partial = @object.class.to_s.underscore
    @local = :"#{@object.class.to_s.underscore}"
  end

  def create_step_2
    OrganisationSession.set( :id => 1 )

    @object = params[:bank].present? ? Bank.new(params[:bank]) : CashRegister.new(params[:cash_register])
    @object.currency_id = session[:org].currency_id

    if @object.valid?
      session[:step]     = 3
      session[:max_step] = 3 if session[:max_step] < 3
      session[:account] = @object
      @partial = "view"
      @local = :view
    else
      @partial = @object.class.to_s.underscore
      @local = :"#{@object.class.to_s.underscore}"
    end
  end

  def get_step_3
    @local = :view
    @partial = "view"
  end

  # Define the partial based on the step
  def set_step_partial
    session[:step] ||= 1

    case session[:step]
    when 1 then @partial = "form"
    when 2 then @partial = "account"
    when 3 then @partial = "view"
    end
  end

  # Sets the object for the step
  def set_object_by_step
    session[:step] ||= 1

    data = request.get? ? session : params

    case session[:step]
    when 1
      @object = @organisation = Organisation.new(data)
    when 2
      @object = @account = Bank.new()
    end
  end

  # Returns the method to be used when creating a new organisation
  def get_save_or_valid(step)
    if step == 3
      :save
    else
      :valid?
    end
  end

end
