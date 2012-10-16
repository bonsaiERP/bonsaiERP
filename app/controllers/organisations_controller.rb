# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class OrganisationsController < ApplicationController
  before_filter :check_tenant_creation

  # GET /organisations/new
  def new
    @organisation = current_organisation
  end

  # POST /organisations
  def update
    @organisation = current_organisation
    @organisation.attributes = params[:organisation]

    if @organisation.save
      flash[:notice] = "Se ha creado su empresa correctamente."
      job = QU.enqueue CreateTenant, @organisation.id, session[:user_id]

      redirect_to @organisation
    else
      render 'new'
    end
  end

  private

    def check_tenant_creation
      if !current_organisation || !session[:tenan_creation]
        redirect_to new_registration_path, error: "Ha ingresado incorrectamente a un recurso."
        return
      end
    end
end
