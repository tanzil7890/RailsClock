module RailsClocks
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout 'railsclocks/application'

    before_action :authenticate_user! if defined?(Devise)
    before_action :ensure_authorized

    private

    def ensure_authorized
      return if RailsClocks.configuration.authorization_proc.call(current_user)
      
      flash[:error] = "You are not authorized to access RailsClocks"
      redirect_to main_app.root_path
    end
  end
end 