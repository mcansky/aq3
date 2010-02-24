class BeansController < ApplicationController
  def new
    a_bean = Bean.new
    a_bean.aq_repository = AqRepository.find(params[:repository_id])
    a_bean.user = current_user
    a_bean.save
    redirect_to a_bean.aq_repository
  end
end
