class AqRepositoriesController < ApplicationController

  def index
    @repositories = AqRepository.find(:all)
  end

  def show
    @repository = AqRepository.find(params[:id])
  end

  def new
    @repository = AqRepository.new
  end

  def create
    @repository = AqRepository.new(params[:aq_repository])
    if @repository.save
      flash[:notice] = t(:repo_create_ok)
      redirect_to @repository
    else
      flash[:notice] = t(:repo_create_ko)
      redirect_to aq_repositories
    end
  end

  def edit
    @repository = AqRepository.find(params[:id])
  end

  def update
    @repository = AqRepository.find(params[:id])
    if @repository.update_attributes(params[:aq_repository])
      flash[:notice] = t(:repo_update_ok)
      redirect_to @repository
    else
      render :action => 'edit'
    end
  end

  def destroy
    repository = AqRepository.find(params[:id])
    repository.destroy
    flash[:notice] = t(:repo_destroy_ok)
    redirect_to root_url
  end

end
