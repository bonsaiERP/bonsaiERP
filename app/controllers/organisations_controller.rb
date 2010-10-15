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
    @organisations = Organisation.all
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
    @organisation = Organisation.new
    respond_with(@organisation)
  end

  # GET /organisations/1/edit
  def edit
    @organisation = Organisation.find(params[:id])
    respond_with(@organisation)
  end

  # POST /organisations
  # POST /organisations.xml
  def create
    # extra step because it gives error in the model
    params[:organisation][:currency_ids] = [ params[:organisation][:currency_id] ]
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      redirect_to(organisation_url(@organisation), :notice => "Se ha creado la empresa")
    else
      add_flash_error(@organisation)
      flash[:notice] = I18n.t("organisation.flash.error")
    end
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
    @organisation = Link.orgs.find{ |v| v.id == params[:id].to_i }

    unless @organisation.blank?
      set_organisation_session(@organisation)
      redirect_to dashboard_url
    else
      flash[:error] = "Debe seleccionar una organización válida"
      redirect_to organisations_path
    end
  end

end
