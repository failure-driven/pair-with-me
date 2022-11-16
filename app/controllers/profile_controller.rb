# frozen_string_literal: true

class ProfileController < ApplicationController
  def index
    redirect_to "/#{current_user.username}"
  end

  def show
    @user = User.find_by(username: params[:id])
  end
end
