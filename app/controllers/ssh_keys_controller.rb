class SshKeysController < ApplicationController
  before_filter :login_required

  def index
    @keys = current_user.ssh_keys
  end
  
  def show
    @key = SshKey.find(params[:id])
    if @key.user != current_user
      flash[:notice] = t(:sshkey_not_owner)
      @key = nil
      redirect_to root_url
    end
  end
  
  def new
    @key = SshKey.new
  end
  
  def create
    @key = SshKey.new(params[:ssh_key])
    @key.user = current_user
    @key.extract_login
    if @key.save
      flash[:notice] = t(:sshkey_created_ok)
      redirect_to @key
    else
      render :action => 'new'
    end
  end
  
  def edit
    @key = SshKey.find(params[:id])
    if @key.user != current_user
      flash[:notice] = t(:sshkey_not_owner)
      @key = nil
      redirect_to root_url
    end
  end
  
  def update
    @key = SshKey.find(params[:id])
    if @key.user == current_user
      if @key.update_attributes(params[:ssh_key])
        @key.extract_login
        flash[:notice] = t(:sshkey_update_ok)
        redirect_to @key
      else
        render :action => 'edit'
      end
    else
      flash[:notice] = t(:sshkey_not_owner)
    end
  end
  
  def destroy
    @key = SshKey.find(params[:id])
    @key.destroy
    flash[:notice] = t(:sshkey_destroy_ok)
    redirect_to ssh_keys_url
  end
end
