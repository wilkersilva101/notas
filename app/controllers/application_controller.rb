class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :layout_by_resource

  rescue_from CanCan::AccessDenied do |exception|
    if exception.action == :destroy && exception.subject == current_user
      redirect_to users_path, alert: t("flash.users.destroy.self_delete_forbidden")
    else
      redirect_to root_path, alert: "Você não tem permissão para acessar esta página."
    end
  end

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
