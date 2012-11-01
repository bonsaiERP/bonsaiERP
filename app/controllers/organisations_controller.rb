# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_filter :check_tenant_creation
  skip_before_filter :set_tenant

  # GET /organisations/new
  def new
    @organisation = current_organisation
  end

  # POST /organisations
  def update
    @organisation = current_organisation
    @organisation.attributes = params[:organisation]

    tenant = TenantCreator.new(@organisation) # Should be background process

    if @organisation.save && tenant.create_tenant
      session[:organisation] = {id: current_organisation.id}
      flash[:notice] = "Se ha creado su empresa correctamente."
      #job = QU.enqueue CreateTenant, @organisation.id, session[:user_id]

      redirect_to dashboard_path
    else
      render 'new'
    end
  end

  private

    def check_tenant_creation
      if !current_organisation || !session[:tenant_creation]
        redirect_to new_registration_path, alert: "Debe confirmar su registro o registrarse."
        return
      end
    end
end
