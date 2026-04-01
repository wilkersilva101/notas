class PostsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  # GET /posts or /posts.json
  def index
    @q = @posts.ransack(params[:q])
    @posts = @q.result(distinct: true).page(params[:page]).per(6)
  end

  # GET /posts/1 or /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = current_user.posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: t("flash.posts.create.notice") }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        if current_user.has_role?(:admin) && @post.user != current_user
          Notification.create!(user: @post.user, message: "O Admin alterou o seu post: '#{@post.titulo}'.")
        end
        format.html { redirect_to @post, notice: t("flash.posts.update.notice"), status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    owner = @post.user
    title = @post.titulo
    @post.destroy!

    if current_user.has_role?(:admin) && owner != current_user
      Notification.create!(user: owner, message: "O Admin excluiu o seu post: '#{title}'.")
    end

    respond_to do |format|
      format.html { redirect_to posts_path, alert: t("flash.posts.destroy.notice"), status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :titulo, :descricao ])
    end
end
