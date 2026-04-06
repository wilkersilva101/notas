module Admin
  class AnnouncementsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin!

    def new
    end

    def create
      message = params[:message]
      if message.present?
        BroadcastAdminAnnouncementJob.perform_later(message)
        redirect_to new_admin_announcement_path, notice: "Aviso em processamento! As notificações serão geradas em background para todos os usuários."
      else
        redirect_to new_admin_announcement_path, alert: "A mensagem do aviso não pode estar vazia."
      end
    end

    private

    def authenticate_admin!
      redirect_to root_path, alert: "Você não tem permissão para acessar esta página." unless current_user&.admin?
    end
  end
end
