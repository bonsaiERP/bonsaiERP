class OrganisationsController < ApplicationController
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
    @organisation.set_user(current_user) # Sets the current user with de organization
    if @organisation.save
      flash[:notice] = I18n.t("organisation.flash.create")
    else
      add_flash_error(@organisation)
      flash[:notice] = I18n.t("organisation.flash.error")
    end
  end

  # PUT /organisations/1
  # PUT /organisations/1.xml
  def update
    @organisation = Organisation.find(params[:id])

    respond_to do |format|
      if @organisation.update_attributes(params[:organisation])
        format.html { redirect_to(@organisation, :notice => 'Organisation was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @organisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.xml
  def destroy
    @organisation = Organisation.find(params[:id])
    @organisation.destroy

    respond_to do |format|
      format.html { redirect_to(organisations_url) }
      format.xml  { head :ok }
    end
  end

end
