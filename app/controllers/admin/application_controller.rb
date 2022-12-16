# frozen_string_literal: true

# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module Admin
  class ApplicationController < Administrate::ApplicationController
    # NOTE: probably swtich to Pundit or similar in future
    NotAuthorized = Class.new(StandardError)
    before_action :authenticate_admin

    def authenticate_admin
      authenticate_user!
      raise NotAuthorized unless current_user.admin?
    end

    # Override this value to specify the number of elements to display at a time
    # on index pages. Defaults to 20.
    # def records_per_page
    #   params[:per_page] || 20
    # end

    rescue_from ApplicationController::NotAuthorized do |exception|
      redirect_to root_path, alert: t("Not Authorized")
    end
  end
end
