# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :destroy_organisation_session!, :except => :select

  respond_to :html, :xml, :json
  # GET /organisations
  # GET /organisations.xml
  def index
    destroy_organisation_session!
    @organisations = current_user.organisations
    respond_with(@organisations)
  end

  # GET /organisations/1
  # GET /organisations/1.xml
  def show
    @organisation = Organisation.find(params[:id])
    set_organisation_session(@organisation)
    respond_with(@organisation)
  end

  # GET /organisations/new
  # GET /organisations/new.xml
  def new
    session[:step] = params[:step] || 1
    session[:max_step] ||= 1

    send(:"get_step_#{session[:step]}")
  end

  # GET /organisations/1/edit
  def edit
    @organisation = Organisation.find(params[:id])
    respond_with(@organisation)
  end

  # POST /organisations
  # POST /organisations.xml
  def create
    if params[:step].present? and params[:step].to_i < 4
      send(:"create_step_#{params[:step]}")
    else
      get_step_1
    end
    
    render :action => 'new'
  end

  # PUT /organisations/1
  # PUT /organisations/1.xml
  def update
    @organisation = Organisation.find(params[:id])
    @organisation.update_attributes(params[:organisation])
    respond_with(@organisation)
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.xml
  def destroy
    @organisation = Organisation.find(params[:id])
    @organisation.destroy

    respond_with(@organisation)
  end

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

private
  # Steps for organisation creation
  def get_step_1
    @partial = "form"
    @local = :organisation
    @object = session[:org] || Organisation.new(:currency_id => 1)
  end

  def create_step_1
    @object = Organisation.new(params[:organisation])
    if @object.valid?
      session[:org]      = @organisation
      session[:step]     = 2
      session[:max_step] = 2 if session[:max_step] < 2
      
      get_step_2
    else
      @partial = "form"
      @local = :organisation
    end
  end

  def get_step_2
    @object = params[:type] == "Bank" ? Bank.new(params[:bank]) : CashRegister.new(params[:cash_register])
    @partial = "bank"
    @local = :bank
  end

  def create_step_2
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
