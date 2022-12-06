# frozen_string_literal: true

require "user_service"

class ProfileController < ApplicationController
  def index
    redirect_to "/#{current_user.username}"
  end

  def show
    @user = UserService.find(params[:id])
    if @user
      @pairs = @user.pairs
      if @user.username != params[:id]
        redirect_to "/#{@user.username}"
      end
    else
      redirect_to root_path, notice: t("user not found")
    end
  end
end
