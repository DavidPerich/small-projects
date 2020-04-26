class ProjectsController < ApplicationController
  before_action :set_project, only: [:edit, :update, :show, :destroy]
  # before_action :require_same_user, except: [:index, :show]
  before_action :require_user, except: [:index, :show]


  def index
    @projects = Project.all
  end

  def show

  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      flash[:notice] = "Your project was created"
      redirect_to projects_path
    else
      flash.now[:error] = "Something went wrong"
      render :new
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      flash[:notice] = "Your project was updated"
      redirect_to project_path(@project)
    else
      flash.now[:error] = "Something went wrong"
      render :edit
    end
  end

  def destroy
    if @project.destroy
      flash[:notice] = "Your project was deleted"
      redirect_to root_path
    else
      flash.now[:error] = "Record unable to be deleted"
      render :show
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end