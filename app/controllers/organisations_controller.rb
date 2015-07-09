# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_action :check_tenant_creation, :check_user_master_account
  skip_before_action :set_tenant, :check_authorization!

  # GET /organisations/new
  def new
  end

  # POST /organisations
  def update
    current_organisation.attributes = organisation_params

    tenant = TenantCreator.new(@organisation) # Should be background process

    if current_organisation.save && tenant.create_tenant
      session[:organisation] = {id: current_organisation.id}
      flash[:notice] = "Se ha creado su empresa correctamente."
      #job = QU.enqueue CreateTenant, @organisation.id, session[:user_id]

      redirect_to dashboard_path
    else
      render :new
    end
  end

  private

    def check_tenant_creation
      unless current_organisation
        redirect_to new_registration_path, alert: "Debe confirmar su registro o registrarse." and return
      end

      if current_tenant && PgTools.schema_exists?(current_organisation.tenant)
        redirect_to  dashboard_url(host: request.domain, subdomain: org.tenant, auth_token: user.auth_token) and return
      end
    end

    def check_tenant_exists

    end

    def organisation_params
      params.require(:organisation).permit(:name, :currency, :country_code,
                                          :time_zone,:phone, :mobile, :email,
                                          :address)
    end

    def check_user_master_account
      unless user_with_role.master_account?
        redirect_to sessions_url(subdomain: false) and return
      end
    end
end
