class RightsController < ApplicationController
  def accept
    right = Right.find(params[:id])
    right.status = "a"
    right.save
    redirect_to right.aq_repository
  end

  def reject
    right = Right.find(params[:id])
    right.status = "r"
    right.save
    redirect_to right.aq_repository
  end
end
