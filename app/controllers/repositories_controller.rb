class RepositoriesController < ApplicationController

  def index
    @repositories = AqRepo.find(:all)
  end

  def show
    @repository = AqRepo.find(params[:id])
  end

  def new
    @repository = AqRepo.new
  end

  def create
    @respoitory = AqRepos.new(params[:repository])
  end

  def edit
    @repository = AqRepo.find(params[:id])
  end

  def update
    @repository = AqRepo.find(params[:id])
    if @repository.update_attributes(params[:repository])
      flash[:notice] = t(:repo_update_ok)
      redirect_to @repository
    else
      render :action => 'edit'
    end
  end

  def destroy
    repository = AqRepo.find(params[:id])
    repository.destroy
    flash[:notice] = t(:repo_destroy_ok)
    redirect_to root_url
  end

end
