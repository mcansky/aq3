class AqRepositoriesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

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
    @repository.owner = current_user
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
    if @repository.owner != current_user
      @repository = nil
      flash[:notice] = t(:insufficient_rights)
      redirect_to root_path
    end
  end

  def update
    @repository = AqRepository.find(params[:id])
    if @repository.rights.size == 0
      a_right = Right.new
      a_right.user = current_user
      a_right.aq_repository = @repository
      a_right.right = 'w'
      a_right.role = 'o'
      @repository.rights << a_right
      a_right.save
    end
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

  def join
    repository = AqRepository.find(params[:id])
    if !repository.users.include?(current_user)
      a_right = Right.new
      a_right.role = "c"
      a_right.right = "r"
      a_right.status = "p"
      a_right.user = current_user
      repository.rights << a_right
      repository.save
    end
    redirect_to repository
  end

  def fork
    parent_repo = AqRepository.find(params[:id])
    repository = AqRepository.new
    repository.fork(parent_repo)
    repository.save if repository
    redirect_to repository
  end

end
