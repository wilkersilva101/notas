class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @q = @users.ransack(params[:q])
    @users = @q.result(distinct: true)
  end

  def show
  end

  def edit
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to users_path, notice: 'Usuário atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, alert: t("flash.users.destroy.notice")
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
