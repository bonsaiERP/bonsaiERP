class OrganisationsController < ApplicationController
  before_filter :destroy_organisation_id

  respond_to :html, :xml, :json
  # GET /organisations
  # GET /organisations.xml
  def index
    @organisations = Organisation.all
    respond_with(@organisations)
  end

  # GET /organisations/1
  # GET /organisations/1.xml
  def show
    @organisation = Organisation.find(params[:id])
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
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      flash[:notice] = I18n.t("organisation.flash.create")
      redirect_to(organisation_url(@organisation))
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
  def select
    session[:organisation_id] = params[:id].to_i
    redirect_to dashboard_url
  end

private
  def destroy_organisation_id
    session[:organisation_id] = nil
  end
end
