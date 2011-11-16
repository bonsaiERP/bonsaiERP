# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
class ProjectsController < ApplicationController
  before_filter :check_authorization!
  before_filter :set_project, :only => [:show, :edit, :update, :destroy]
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new(:active => true)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    if @project.save
      redirect_ajax(@project, :notice => 'El project fue creado.')
    else
      render :action => "new"
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    if @project.update_attributes(params[:project])
      redirect_to(@project, :notice => 'El project fue actualizado.')
    else
      render :action => "edit"
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project.destroy
    redirect_ajax @project
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end
