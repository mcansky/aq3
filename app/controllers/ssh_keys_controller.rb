class SshKeysController < ApplicationController
  def index
    @keys = SshKey.all
  end
  
  def show
    @key = SshKey.find(params[:id])
  end
  
  def new
    @key = SshKey.new
  end
  
  def create
    @key = SshKey.new(params[:ssh_key])
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
  end
  
  def update
    @key = SshKey.find(params[:id])
    if @key.update_attributes(params[:ssh_key])
      @key.extract_login
      flash[:notice] = t(:sshkey_update_ok)
      redirect_to @key
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @key = SshKey.find(params[:id])
    @key.destroy
    flash[:notice] = t(:sshkey_destroy_ok)
    redirect_to ssh_keys_url
  end
end
